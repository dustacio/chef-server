#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
#
# All Rights Reserved

opscode_erchef_dir = node['private_chef']['opscode-erchef']['dir']
opscode_erchef_log_dir = node['private_chef']['opscode-erchef']['log_directory']
opscode_erchef_sasl_log_dir = File.join(opscode_erchef_log_dir, "sasl")
[
  opscode_erchef_dir,
  opscode_erchef_log_dir,
  opscode_erchef_sasl_log_dir
].each do |dir_name|
  directory dir_name do
    owner OmnibusHelper.new(node).ownership['owner']
    group OmnibusHelper.new(node).ownership['group']
    mode node['private_chef']['service_dir_perms']
    recursive true
  end
end

link "/opt/opscode/embedded/service/opscode-erchef/log" do
  to opscode_erchef_log_dir
end

ldap_authentication_enabled = OmnibusHelper.new(node).ldap_authentication_enabled?
 # These values are validated and managed in libraries/private_chef.rb#gen_ldap
enable_ssl = ldap_authentication_enabled ? node['private_chef']['ldap']['enable_ssl'] : nil
ldap_encryption_type = ldap_authentication_enabled ? node['private_chef']['ldap']['encryption_type'] : nil

erchef_config = File.join(opscode_erchef_dir, "sys.config")

rabbitmq = OmnibusHelper.new(node).rabbitmq_configuration

actions_vip = rabbitmq['vip']
actions_port = rabbitmq['node_port']
actions_user = rabbitmq['actions_user']
actions_password = rabbitmq['actions_password']
actions_vhost = rabbitmq['actions_vhost']
actions_exchange = rabbitmq['actions_exchange']

template erchef_config do
  source "oc_erchef.config.erb"
  owner OmnibusHelper.new(node).ownership['owner']
  group OmnibusHelper.new(node).ownership['group']
  mode "644"
  variables(node['private_chef']['opscode-erchef'].to_hash.merge(:ldap_enabled => ldap_authentication_enabled,
                                                                 :enable_ssl =>  enable_ssl,
                                                                 :actions_vip => actions_vip,
                                                                 :actions_port => actions_port,
                                                                 :actions_user => actions_user,
                                                                 :actions_password => actions_password,
                                                                 :actions_vhost => actions_vhost,
                                                                 :actions_exchange => actions_exchange,
                                                                 :ldap_encryption_type => ldap_encryption_type,
                                                                 :helper => OmnibusHelper.new(node)))
  notifies :run, 'execute[remove_erchef_siz_files]', :immediately
  notifies :restart, 'runit_service[opscode-erchef]' unless backend_secondary?
end

# Erchef still ultimately uses disk_log [1] for request logging, and if
# you change the log file sizing in the configuration **without also
# issuing a call to disk_log:change_size/2, Erchef won't start.
#
# Since we currently don't perform live upgrades, we can fake this by
# removing the *.siz files, which is where disk_log looks to determine
# what size the log files should be in the first place.  If they're
# not there, then we just use whatever size is listed in the
# configuration.
#
# [1]: http://erlang.org/doc/man/disk_log.html
execute "remove_erchef_siz_files" do
  command "rm -f *.siz"
  cwd node['private_chef']['opscode-erchef']['log_directory']
  action :nothing
end

link "/opt/opscode/embedded/service/opscode-erchef/sys.config" do
  to erchef_config
end

component_runit_service "opscode-erchef"
