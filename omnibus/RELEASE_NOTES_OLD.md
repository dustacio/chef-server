This document contains historical release notes. See
[RELEASE\_NOTES.md](RELEASE_NOTES.md) for the current version's release
notes.

## 12.1.2 (2015-07-16)

Fix issue where chef-server-ctl install could not fetch remote packages via apt.

## 12.1.1 (2015-07-13)

This is a bug fix release which fixes bugs related to upgrades from
Open Source and Enterprise Chef 11.

This release also ships openssl 1.0.1p; however, Chef Server was not
vulnerable to CVE-2015-1793 since no version of Chef Server shipped
the affected versions.

## 12.1.0 (2015-06-18)

The following items are new since Chef Server 12.0.8 and/or are changes from
previous versions.  For specific breakdown of updated components, refer to
CHANGELOG.md.

Additional items will be highlighted here for further RC updates, then
consolidated into the overall 12.1.0 release notes as part of the final
12.1.0 release.

### Chef Server
  * Expose queue configuration for erchef and bifrost connection pools
  * A new gather-log script gathers a lot more debugging information for
    use in support requests.
  * Optionally send application statistics using the statsd
    protocol. To send statsd-formatted statistics,
    set `estatsd['protocol'] = "statsd"` in chef-server.rb.
  * expose postgres WAL configurables in chef-server.rb
  * chef-server-ctl key commands now use the keys API
  * remove darklaunch flags that controlled routing of requests to couch
    vs postgres, and oc_erchef vs opscode-account.
  * Fix local-mode-cache warnings on `chef-server-ctl reconfigure`
  * Erlang runtime upgraded to 17.5

#### Chef Server Development Improvements

* Many of Chef Server's components have been consolidated, allowing
  Chef to increase the rate at which we can deliver improvements. The
  new consolidated repository can be found at
  https://github.com/chef/chef-server.
* A new self-contained development environment greatly simplifies and
  speeds up the process of developing Chef Server components.  This
  also eases the path for those outside of the Chef organization
  who wish to contribute to Chef Server. You can find this here:
  https://github.com/chef/chef-server/tree/master/dev.  Feedback and
  suggestions are welcome.
* Many less-visible improvements all contribute to making Chef Server
  easier to enhance and maintain, including improved test coverage,
  better static code analysis, coverage analysis, removal of redundant
  paths, unified build/make process, and extensive refactoring of code.

### REST API Service (oc\_erchef)
  * Server API version is now `1`, and this release deprecates API v0.
    See Deprecations below for more information.
  * All support for couch has been removed, along with darklaunch flags
    that would allow switching between CouchDB and Postgres.
  * New behaviors introduced under APIv1 for Clients, Users, and Principals.  See
    API Changes and Additions
  * Multiple performance enhancements:
    * Improve performance of depsolver endpoint by using a bulk query for
      cookbook versions.
    * Reduce bulk query to retrieve minimum required data, which
      provided a significant performance improvement.
    * Changes to reduce the number of redundant database calls made from many
      endpoints
    * Eliminate unecessary postgresql transactions caused by recent versions of sqerl.
    * Wire-level performance enhancements for postgres communications that
      significantly reduce the number of network packets required for
      most transactions.


### Authorization Service (oc\_bifrost)

  * Wire-level performance enhancements for postgres
  * Eliminate unecessary postgresql transactions caused by recent versions of sqerl.

### Identity Service (oc\_id)

  * Ensure that unless newrelic support is expressly configured, the
    service will not call home to newrelic.
  * The UI has been updated as part of our ongoing effort to improve the look
    and feel of all Chef applications.

### Deprecations

  * Server API version is currently `1`.  Version `0` is deprecated.
    This includes several v0 behaviors for the Users, Clients and
    Prinicpals endpoints.  See API Changes and Additions for more details.
  * The response header `X-Ops-API-Info` is also deprecated. Version `0`
    requests will continue to receive it alongside the new
    `X-Ops-Server-API-Version` header, while Version `1`+ will receive only
    the latter.

### Changes in Behavior

  * As a side effect of keys-related changes Clients under
    API v1, searches for clients created using v1 of the API will no longer
    include client public keys in the response.  When API v0 is
    desupported, this will become the default behavior.

### Bug Fixes / Closed Issues

  * API requests made by a user that shares a name with a client in the
    same org wil no longer fail with a 401.
  * Fix bug where chef-server-ctl install command would
    always attempt to reinstall previously installed packages.
  * Fix a fatal `oc_erchef` crash that occurred when `folsom_graphite` is configured,
    but no server is avaiable or the server goes away.
  * Prevent graphite failures from causing `oc_erchef` to crash when
    `folsom_graphite` is enabled.
  * Pull in newest folsom and bear to address `folsome_graphite` crashes.
  * Fix local-mode-cache warnings on `chef-server-ctl reconfigure`
    (Issue #106)
  * Restart procps server to ensure sysctl tuning is applied.
  * Correct path to DRBD split brain notification script.
  * Remove install message from postinst package script
  * Fix bug where `chef-server-ctl reconfigure` would
    fail if rabbitmq['nodename'] had been changed.
  * Fixes chef-server issue #119 which prevented some LDAP users from
    successfully logging in.
  * Correct path to DRBD split brain notification script.
  * Redact password from actions data, if present.

### Security Updates

The following items are the security updates that have been applied since Chef Server 12.0.8:

* PostgreSQL 9.2.10
  * CVE-2015-0241 - Fix buffer overruns in `to_char()`
  * CVE-2015-0242 - Fix buffer overrun in replacement `*printf()` functions
  * CVE-2015-0243 - Fix buffer overruns in `contrib/pgcrypto`
  * CVE-2015-0244 - Fix possible loss of frontend/backend protocol synchronization
    after an error
  * CVE-2014-8161 - Fix information leak via constraint-violation error messages
  * CVE-2014-0067 - Lock down regression testing's temporary installations on Windows
* Redact password from actions data, if present.
* Redis 2.8.21
  * CVE-2015-4335: Redis Lua Sandbox Escape

### API Changes and Additions

Complete API change documentation and coverage of new features will be
be provided with the 12.1.0 final final release.

Server API Version support is enabled via the `X-Ops-Server-API-Version`
request header. Current valid values are `0` and `1`.

Server API Version `0` is deprecated with the release of 12.1.0.

*Changes implemented under API v0+*

These additions and behaviors are in effect for API v0 and any later versions:

  * Policyfile, Policy Groups, and Cookbook Artifact endpoints are now
    considered final and are available for use.
  * When creating or updating a key via the Keys API, it is now possible
    to include `create_key: true` in the request body to use a server-generated
    private key. In this case, the fields `public_key` and `private_key` will be
    returned along with the existing response body.
  * If request header `X-Ops-Server-API-Version` is not provided by the
    client, be considered `0` instead of the lowest-supported version.
  * Response header `X-Ops-Server-API-Version` has been implemented for
    all requests, and will indicate the version level at which each
    request was services.
  * In client creation and update, the last remnants of the `admin` flag
    have been removed. It was previously partially supported in that we
    would capture and update the value, but the value was unused in the system.
    If submitted in POST/PUT of a client or user, it is ignored.

*Changes implemented under API v1+*

These changes are in effect only if the requestor specifies API version
of `1` or higher. Clients that do not request this version or explicitly
request version `0` will continue to see unmodified behavior under API
v0, until that version is desupported.

  * Response header X-Ops-API-Info is not included in responses.
  * Clients and Users
    * GET of named client/user will no longer include a `public_key`
      field.  Instead use `GET /clients/:name/keys` to list keys, and
      `GET /clients/:name/keys/:key_name` to view the `public_key`
      value.
    * A default key can be created when POSTing create a new client or user
      by including either a `public_key` value or `create_key: true` in
      the request body.
    * If neither `public_key` nor `create_key` is provided in the request
      body, the client or user will be created without a key.  A key can
      be added later via the keys endpoint for the client/user.
    * Certificates are no longer accepted as a valid `public_key` value
      when POSTing to create a client. Only public keys are accepted.
    * Keys can no longer be updated via a PUT request to client or user -
      instead perform the PUT request to the keys endpoint.
    * Including any of `public_key`, `private_key`, or `create_key` in PUT
      requests to client/users will cause a 400 response with detailed message.
    * If a key is created for a new client or user via `public_key` or `create_key`,
      a `chef_key` object will be included in the response. The `chef_key` will
      also include the key's URL which can be used for updates and removal.
      If the key has been generated by the server, then `private_key` will
      be included in the embedded `chef_key`.
  * The Principals endpoint will return a list of principal data for all
    matching principals within a container object in the form
    `{ "principals" : [{...},... ] }`.  The fields within each `principal`
    record in the list are unmodified from v0.

#### Compatibility Notes

  * Client Support for APIv1 is underway and is expected to be released
    shortly.
  * Current server Add-Ons will work with 12.1.0.  However, reporting,
    push server, and analytics may not work correctly if multiple keys are
    configured for clients or users. Updates to these products to enable
    support for Chef Server API v1 and multi-key are forthcoming.
  * If you are upgrading from 12.0.7 or earlier and have any existing
    organizations that does not have the default `users`, `admins`, and/or
    `clients` groups, then policyfiles, policy groups, and cookbook artifacts
    may  not work correctly for these organizations.  If your existing
    organizations do have these groups, then the new endpoints will work
    as expected.

### Release History

* RC1 - 2015-05-27 (internal)

## 12.0.8 (2015-04-20)

The following items are new since Chef Server 12.0.7 and/or are changes from previous versions.  For specific breakdown of updated components, refer to CHANGELOG.md

* oc\_erchef
  * Server API Versioning is now enabled and current API version is `0`.
    See chef-rfc/rfc-041 for details on server API versioning support.
* `chef-server-ctl`
  * has been updated to use the Keys API for key management commands.
  * `--enable-external-auth` option to command `chef-server-ctl password` has been fixed

### Security Updates

The following items are the security updates that have been applied since Chef Server 12.0.7

* OpenResty 1.7.7.10 (nginx)
  * CVE-2013-2028 - a stack-based buffer overflow might occur in a worker process while handling a specially crafted request, potentially resulting in a   rbitrary code execution
  * CVE-2013-4547 - a character following an unescaped space in a request line was handled incorrectly
  * CVE-2014-0088 -  memory corruption might occur in a worker process on 32-bit platforms while handling a specially crafted request by `ngx_http_spdy_module`, potentially resulting in arbitrary code execution
  * CVE-2014-0133 - a heap memory buffer overflow might occur in a worker process while handling a specially crafted request by `ngx_http_spdy_module`, potentially resulting in arbitrary code execution
  * CVE-2014-3556 - pipelined commands were not discarded after STARTTLS command in SMTP proxy
  * CVE-2014-3616 - it was possible to reuse SSL sessions in unrelated contexts if a shared SSL session cache or the same TLS session ticket key was used for multiple "server" blocks

### Issue Fixes
  * [opscode-omnibus-744](https://github.com/chef/opscode-omnibus/issues/744)
  * [chef-server-142](https://github.com/chef/chef-server/issues/142)

## 12.0.7 (2015-03-26)

The following items are new since Chef Server 12.0.6 and/or are changes from previous versions.
For specific breakdown of updated components, refer to CHANGELOG.md

  * Implements the minimum set of Policyfile endpoints required for end
    to end usage of Policyfiles. Requires Chef Client 12.2+ and ChefDK
    0.5+. The upgrade process is still being tested so this only works
    with a brand new installation, and you must set
    `lb["xdl_defaults"]["policies"] = true` in the `chef-server.rb`
    file. Chef Client and ChefDK also require feature flags in their
    respective configurations to enable "native" Policyfile APIs.

  * Search results respect ACLs. (Disabled by default)
    To enable, ensure that `opscode_erchef['strict_search_result_acls']`
    is set to `true` in `chef-server.rb`. This will default to enabled
    in the next major version.

## 12.0.6 (2015-03-19)

The following items are new since Chef Server 12.0.5 and/or are changes from previous versions.
For specific breakdown of updated components, refer to CHANGELOG.md

* opscode-omnibus
  * Use a cert instead of a public key for the superuser.
  * No longer generate /etc/opscode/pivotal.cert as it is no longer used. Now the public key for the superuser lives in the database and no longer exists on disk.
* oc\_erchef
  * Key API Updates - GET, PUT and DELETE  of named keys now supported
  * Policyfile validation support. (See API Changes, below.)

### Closed Issues
* [chef-server-119](https://github.com/chef/chef-server/issues/119)
* [chef-server-97](https://github.com/chef/chef-server/issues/97)
* [chef-server-17](https://github.com/chef/chef-server/issues/17)
* [opscode-omnibus-648](https://github.com/chef/opscode-omnibus/issues/648)


### API Changes and Additions
* new: `GET`/`PUT`/`DELETE` to `/users/USERNAME/keys/KEYNAME` can be used to get
  view, update or delete a user key.
* new: `GET`/`PUT`/`DELETE` to  `/organizations/ORGNAME/clients/CLIENTNAME/keys/KEYNAME` can be
  used to get view, update or delete a client key.
* new: [Policyfile](https://github.com/chef/chef-rfc/pull/91) support
  for Policfyile validation.  Policyfile is disabled by default, stay tuned for
  further updates in this space.

### Security Updates

* OpenSSL 1.0.1m - CVE-2015-0286: Segmentation fault in ASN1_TYPE_cmp fix
* OpenSSL 1.0.1m - CVE-2015-0287: ASN.1 structure reuse memory corruption fix
* OpenSSL 1.0.1m - CVE-2015-0289: PKCS7 NULL pointer dereferences fix
* OpenSSL 1.0.1m - CVE-2015-0293: DoS via reachable assert in SSLv2 servers fix
* OpenSSL 1.0.1m - CVE-2015-0209: Use After Free following d2i_ECPrivatekey error fix
* OpenSSL 1.0.1m - CVE-2015-0288: X509_to_X509_REQ NULL pointer deref fix

## 12.0.5 (2014-02-26)

### What's New

The following items are new since Chef Server 12.0.4 and/or are changes from previous versions.
For specific breakdown of updated components, refer to CHANGELOG.md

* oc\_erchef
  * Updates to user records will no longer clear the
    `external_authentication_uid` and `recovery_auth_enabled` fields if
    those fields are not included in the request.
  * Key API support to post client and user keys. (See API Changes, below)
  * Policyfile API additions. (See API Changes, below.)

### Closed Issues
* [chef-server-110](https://github.com/chef/chef-server/issues/110)
* [chef-server-66](https://github.com/chef/chef-server/issues/66)

### API Changes and Additions
* new: `POST` to `/organizations/ORGNAME/clients/CLIENTNAME/keys`
  can be used to add a client key.
* new: `POST` to `/users/USERNAME/keys`
  can be used to add a user key.
* new: [Policyfile](https://github.com/chef/chef-rfc/pull/91) support to
  `GET` and `POST` to/from `/organization/ORGNAME/cookbook_artifacts/NAME/IDENTIFIER`.
  Policyfile is disabled by default, stay tuned for further updates in this
  space.

## 12.0.4 (2014-02-19)

### What's New:

The following items are new since Chef Server 12.0.3 and/or are changes from previous versions.
For specific breakdown of breakdown of updated components, refer to CHANGELOG.md

* oc\_erchef
  * Cookbook caching is now available. It is off by default - see chef-server.rb tunables
    below for information on how to enable this.
  * Keys API support to list client and user keys. (See API Changes, below.)
  * Policyfile initial API support. (See API Changes, below.)
  * LDAP:
    * multiple values for the same LDAP field no longer cause errors
    * anonymous binds now work properly.
    * re-enhancement: re-added support for `group_dn` ldap attribute to require users to be in the named group.
      This change was originally in 12.0.1 but was lost in our transition to a new repository.
      Thanks to Brian Felton for the original enhancement.
* `chef-server-ctl` has been fixed to properly escape shell metacharacters
  in arguments to user- and org- commands.
* `knife-ec-backup` has been updated with key rotation support
* `chef-server.rb` tunables
  * `ldap['bind_dn']` can now be left unspecified for anonymous binds if
    your LDAP server supports them.  If you wish to use anonymous binding,
    also ensure that `ldap['bind_pass']` is not set.
  * `ldap['group_dn']` set this to the DN of a group to to restrict Chef logins
     to members of a particular group. This feature filters based on the memberOf
     attribute and only works with LDAP servers that provide such an attribute.
  * Cookbook Caching:
    * This is off by default. To fully enable, configure both of the settings
      below:
    * `opscode_erchef['nginx_bookshelf_caching']` is a new setting that is
       configured `:off` by default. To enable, set it to `:on` in your
       `chef-server.rb`.
    * `opscode_erchef['s3_url_expiry_window_size']` is a new setting
      that is set to `:off` by default. For details on valid values and their effects,
      see this [blog post](https://chef.io/blog/2015/02/18/cookbook-caching).
      and [this comment](https://github.com/chef/oc_erchef/blob/master/apps/chef_objects/src/chef_objects.app.src#L89)

### Bug Fixes
  * [chef-server-84](https://github.com/chef/chef-server/issues/84)
  * [chef-server-68](https://github.com/chef/chef-server/issues/68)
  * [chef-server-71](https://github.com/chef/chef-server/issues/71)

### Component Upgrades
  * Ruby 2.1.4
  * Chef 12.0.3 - Chef Server is now internally using Chef Client 12 in local mode
    for its installation and configuration.

### API Changes and Additions
  * new: `GET` to `/organizations/ORGNAME/clients/CLIENTNAME/keys`
    returns a list of keys for a client, and their expiration status.
  * new: `GET` to `/users/USERNAME/keys`
    returns a list of keys for a user, and their expiration status.
  * new: [Policyfile](https://github.com/chef/chef-rfc/pull/91) initial API support.
    This is disabled by default, stay tuned for further updates in this
    space.

## 12.0.3 (2015-02-04)

### What's New:

* Chef 11.18.0
  * Chef 11.18.0 was vendored into the server. This will fix ffi-yajl related warning when running chef-server-ctl commands.

* chef-server-ctl
  * Added key management and rotation commands add-client-key,
    add-user-key, delete-user-key, delete-client-key,
    list-client-keys, and list-user-keys.  This is considered a beta
    feature at this time.

* oc\_erchef
  * BUG FIX: Search results for arrays previously would match values
    from all precedence levels.
  * Preliminary internal support for multiple key authentication and key
    rotation. API support will follow in a subsequent release. This is
    considered a beta feature at this time.

* opscode-omnibus
  * Use X-Forwarded-For header instead of remote address in nginx logs
    when nginx['log_x_forwarded_for'] is set to true

## 12.0.2 (2015-01-27)

The following items are the set of bug fixes that have been applied since Chef Server 12.0.1:

* `chef-mover` can hang during long-running migrations of organizations and user associations.

## 12.0.1 (2014-12-17)

The following components are no longer used and have been removed:
* opscode-test
* opscode-billing
* opscode-shared
* mixlib-authentication

## 12.0.0 (2014-11-25)

### What's New:

The following items are new since Enterprise Chef 11.2.1 and/or are changes from previous versions.

* oc\_erchef
  * All endpoints that formerly were in opscode-account are now in erchef and the data
    resides in PostgreSQL. This includes containers, groups, organizations, org associations and invites.
  * Key generation is now in erchef.
  * See important API change notes below
* The following components are no longer used and have been removed:
  * couchdb
  * opscode-account
  * opscode-certificate
  * opscode-org-creator
  * opscode-webui - removed in favor of the Manage Console add-on
  * orgmapper
* Introduced pluggable HA architecture as alternative to DRBD.
* Solr has been upgraded to Solr 4
* For compatibility with Open Source Chef 11, a new configuration option
  `default_orgname` has been provided.  All org-related requests that are not
  in the form '/organizations/X/...' will be assumed to have this organization name.
* `private-chef.rb` and `chef-server.rb`
  * `private-chef.rb`  has been replaced by `chef-server.rb`
  * if you are upgrading from EC11 and have a `private-chef.rb` in place,
    a symlink from `chef-server.rb` to `private-chef.rb` will be created for
    you when you upgrade.
  * If you do not have a `private-chef.rb` or `chef-server.rb`, a `chef-server.rb`
    will be created for you at installation.
* LDAP
  * STARTTLS is now properly supported for LDAP.  If your LDAP server supports it
    you can enable it via `ldap['start_tls'] = true` in `/etc/opscode/chef-server.rb`.
  * the `ldap['encryption']` setting is deprecated. (See Deprecations
    section, below.)
* chef-server-ctl
  * `chef-server-ctl` replaces `private-chef-ctl` though
    `private-chef-ctl` will also work in CS12.
  * Several commands added related to the management of users and
    organizations, allowing management of organizations without the management console
    or original webui. You can find information about these commands via `chef-server-ctl help`.
    and looking under "Organization and User Management Commands".  You can find usage
    examples at this location: https://docs.chef.io/install_server.html
  * new `gather-logs` command to create a tarball of important logs and system information.
* Org Policy Changes
  * it is now required that a user be removed from an organization's "admins" group
    before being removed from the organization.
  * Data Bag defaults ACLs have been modified so that clients of new
    organizations do not have create/update/delete access.   See "Organization Policy Changes"
    below for more detail and impacts.
* omnibus
  * `oc_chef_authz` settings are now tuneable
  * postgesql slow query logging can now be configured
* Upgrades from Open Source Chef 11.1
  * The `chef-server-ctl upgrade` command has been augmented to support upgrading from Open Source Chef 11.1
     or greater.
    * In addition, three additional chef-server-ctl commands have been added:
      `chef12-upgrade-download`, `chef12-upgrade-data-transform`, and `chef12-upgrade-upload`, which allow
       the upgrade process to be broken down into discrete steps if more control is desired than the upgrade
       command alone provides.
    * Run any of these commands with -h to see the full help menu and all the possible options that can be set.
      In addition, refer to the docs at https://docs.chef.io/upgrade_server.html#from-chef-server-osc and
      https://docs.chef.io/upgrade_server_open_source_notes.html#manual-upgrades for more information.

### Bug Fixes:

The following items are the set of bug fixes that have been applied since Enterprise Chef 11.2:

* [OC-11703] Fix bug that prevents ACL and group expansion when containing group that no longer exists
* [OC-10470] Allow private-chef-ctl status to ignore disabled services
* [OC-11574] private-chef-ctl service commands should be HA-aware
* [OC-9877] Exclude binary files and archives from 'omnibus-ctl tail'
* [opcode-omnibus-597] Ensure postgresql is set with shared memory less than SHMAX.
* Fix `oc_chef_authz` timeout tunable

### Security Updates

Following are security-related component updates introduced since
Enterprise Chef 11.2

* [oc\_erchef] Default data bag ACL change (rc6) details below.
* [opscode-omnibus] Adjust perms to 0750 for all service log directories
* [opscode-omnibus] openssl 1.0.1j to address CVE-2014-3513, CVE-2014-3567, and CVE-2014-3568
* [opscode-omnibus] disable SSLv3 by default at the load balancers
* [opscode-omnibus] Ensure contents of install dir (/opt/opscode) are owned by root.

### API Changes
* `POST` to `/organizations/ORGNAME/groups` now ignores any initial list of users
  and clients provided
* "flavor" header returned from REST API calls is now "cs"
* maximum chef client version is no longer checked

### Organization Policy Changes

*Default Data Bag ACL Change*

Previously, the default permissions of data bags permitted clients
(nodes) to update them, such as during a chef-client run. This has
been modified so that in any new orgs created after this update,
clients will not have write access to data bags.  If you require
the original behavior in organizations created after this update,
you can use the knife acl[1] plugin to add permissions as follows:

    knife acl add containers data update group clients

If you have cookbooks that are creating new data bags, or deleting data
bags, you will also need to add 'create' and 'delete' permissions
respectively:

    knife acl add containers data create group clients
    knife acl add containers data delete group clients

If you want to update your existing organizations to remove
client ability to modify/create/delete new data bags (recommended if you're not
using this currently):

    knife acl remove containers data update group clients
    knife acl remove containers data delete group clients
    knife acl remove containers data create group clients

More information - including examples of modifying permissions for both
newly created data bags and existing data bags data - can be found here:

https://www.chef.io/blog/2014/11/10/security-update-hosted-chef/

[1] knife-acl is a plugin to support managing ACLs using knife, instead
of the opscode-manage interface. It can be found here: https://github.com/chef/knife-acl

*Admins Cannot be Removed From Organizations*

A significant number of the support-related issues that we've seen stem
from admins being able to remove themselves from an organization,
particularly when they are the last admin in the organization (but not
necessarily limited to this).

To help prevent this class of troubles, Chef Server now enforces that a
member of an organization's "admins" group cannot be removed from the
organization without first being removed from the "admins" group.

### Deprecations

* The setting ldap['encryption'] is now deprecated. Instead use
  `ldap['ssl_enabled'] = true` or `ldap['tls_enabled'] = true` as appropriate
  to your environment.

### Release History

* RC7 2014-11-20
* RC6 2014-11-11
* RC5 2014-10-17
* RC4 2014-09-18
* RC3 2014-09-10
* RC2 2014-09-08 (first public)
* RC1 2014-09-07 (internal)

## 11.2.1

### Bug Fixes:

The following items are the set of bug fixes that have been applied since Enterprise Chef 11.2.0:

* Fix issue where 'private-chef' was being changed to 'private\_chef' unexectedly in upstart/runit files

## 11.2.0 (2014-08-29)

### What's New

The following items are new for Enterprise Chef 11.2.0 and/or are
changes from previous versions:

* [private-chef-cookbooks] Add bifrost\_sql\_database uri to orgmapper.conf
* [opscode-platform-debug] Upgrade to rel-0.5.1
* [private-chef-ctl] Add a gather-logs command to create a tarball of
  important logs and system information.
* [oc-id] Add Chef Identity Service.  This enables Supermaket authentication
  with the Chef Server.
* [opscode-analytics]
  * `dark_launch['actions']` defaults to true.  You no longer
  need to manually set this in the private-chef.rb
  * Copy webui\_priv into opscode-analytics if actions is enabled
  * This change adds a new 'oc-id' key to the private-chef-secrets.json.
* [orgmapper] Bump orgmapper to a new minor revision.  This enables support for
  the bifrost/authz API and fixes several bugs.


### Bug Fixes:

The following items are the set of bug fixes that have been applied since Enterprise Chef 11.1.8:

* [OC-11297] tweak partybus migration-level subscribes for a more reliable workaround
* [OC-11585] Allow ['lb']['upstream'] to have a custom setting
* [OC-11459] Allow opscode-manage to easily be moved off of 443
* [OC-11540] Fix invalid opscode-account config when forcing SSL
* [OC-11575] Don't start services by default in HA topology
* [OC-11601] Fix a race condition that sometimes
  caused redis\_lb to attempt to reconfigure itself before it was restarted.
  * This causes redis\_lb to restart during every reconfigure.  This restart can
    cause a short period of 500 errors on the on the FE nodes.
* [OC-11668] enable ipv6 in standalone mode
* [OC-11672] Upgrade PostgreSQL to 9.2.9
* [OC-11673] Tune PostgreSQL keepalive timeouts
* [OC-11702] Fix bug that prevents ACL and group expansion when containing group that no longer exists
* [OC-11708] Fix user association bug when last updater of users group is no longer associated
* [OC-11710] Fix couchdb compaction log rotation

### Security Fixes:

The following items are the set of security fixes that have been applied since Enterprise Chef 11.1.8:

* OpenSSL 1.0.1i addresses CVE-2014-3512, CVE-2014-3511, CVE-2014-3510, CVE-2014-3507, CVE-2014-3506, CVE-2014-3

## 11.1.8 (2014-06-26)

### Bug Fixes:

The following items are the set of bug fixes that have been applied since Enterprise Chef 11.1.6:

* [opscode-omnibus] private-chef-ctl test command should provide pedant return code.
* [opscode-omnibus] Use more strict regular expression for IP check in ha-status
* [opscode-omnibus] Ensure CouchDB compaction cron job does not run on passive backend.
* [OC-11499] Use more strict regular expression for IP check in ha-status
* [OC-3107] Ensure CouchDB compaction cron job does not run on passive backend.
* [OC-11601] Restart redis\_lb immediately during reconfigure
* [OC-11490] Explicitly set keepalived directory ownership
* [OC-11297] EC 11 fresh install not saving migration state in HA topology
* [OC-11656] Set explicit owner and group for services without them
* [OC-11657] Bump default svwait timeout of 7 seconds to 30 seconds
* [OC-11382] keepalived restart interferes with upgrades
* [OC-8881] private-chef-ctl password does not work

### Security Fixes:

The following items are the set of security fixes that have been applied since Enterprise Chef 11.1.6:

* Address a PostgreSQL configuration error. The defect allows any local user on the system hosting the Chef Serv






## 11.1.6 (2014-06-05)

### Security Fixes:

The following items are the set of security fixes that have been applied since Enterprise Chef 11.1.5:

* Address vulnerabilities CVE-2014-0224, CVE-2014-0221, CVE-2014-0195, CVE-2014-3470 https://www.openssl.org/news/secadv_20140605.txt

## 11.1.5 (2014-05-14)

### What's New:
* [oc\_erchef] First release with full compatibility for Chef Actions service

## 11.1.4 (2014-05-07)

### Security Fixes:

The following items are the set of security fixes that have been
applied since Enterprise Chef 11.1.3:

* [bootstrap] Set random initial password for pivotal superuser on bootstrap
* [opscode-account] Prevent password authentication for pivotal superuser

## 11.1.3 (2014-04-09)

### What's New:

The following items are new for Enterprise Chef 11.1.3 and/or are changes from previous versions:

* [core] Erlang r15b03-01 w/ multiple stability and bug fixes
* [core] Chef 11.10.4 (was 11.6.0)
* [core] PostgreSQL 9.2.8 (was 9.2.4)
* [oc\_erchef] Added hooks for opscode-analytics actions service

### Bug Fixes:

The following items are the set of bug fixes that have been applied since Enterprise Chef 11.1.2:

* [opscode-omnibus] Increased postgresql max\_connections to a default of 350 to handle 4 node clusters.
* [opscode-account] Fix for LDAP user creation failure.
* [opscode-omnibus] Manage /var/log/opscode permissions even with non 0022 umask.

* [opscode-omnibus] Separate redis\_keepalive\_timeout from redis\_connection\_timeout and increase their
  default values from 60ms to 1000 and 2000ms, respectively.

### Security Fixes:

The following items are the set of security fixes that have been
applied since Enterprise Chef 11.1.2:

* [opscode-webui] Patch for Denial of Service Vulnerability in Action View when using render :text (CVE-2014-0082)
* [opscode-webui] Patch for Denial of Service Vulnerability in Action View (CVE-2013-6414)
* [opscode-webui] Patch for Reflective XSS Vulnerability in Ruby on Rails (CVE-2013-4491)
* [libcurl] Patch for wrong re-use of connections (CVE-2014-0138)
* [libcurl] Patch for address wildcard certificate validation (CVE-2014-0139)
* [libcurl] Patch for not verifying certs for TLS to IP address / Darwinssl (CVE-2014-1563)
* [libcurl] Patch for not verifying certs for TLS to IP address / Winssl (CVE-2014-2522)
* [openssl] Patch for heartbeat extension exposing process memory (CVE-2014-0160)
* [libyaml] Patch for arbitrary code execution vulnerability (CVE-2014-2525)

## 11.1.2 (2014-02-28)

### Security Fixes:

The following items are the set of security fixes that have been applied since Enterprise Chef 11.1.1:

* [opscode-webui] Don't log or email the Rails session or environment from the exception handler. Doing so can cause user-submitted form values like passwords to be logged and emailed to administrators of the Enterprise Chef server when exceptions occur on the Management Console.
