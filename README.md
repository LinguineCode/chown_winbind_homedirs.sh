chown_winbind_homedirs.sh
=========================

This script will set correct ownership for winbind users in ``/home/MyDomain/``. It is to be used along with:

  1. Puppet
  2. A Samba/Winbind module of your choice
  3. And enough Hiera YAML (or your own Puppet module, if you choose) that will create home directories for your users

This script was created a workaround to Puppet not being able to handle creating home directories my users. Due to this "bug"/missing feature: https://tickets.puppetlabs.com/browse/PUP-3204. In summary: Puppet only references nsswitch ONCE upon starting up. So it has no knowledge of new users/groups that are made available from connecting to external sources. This is a problem when you are using Puppet to configure the external source AND reference the users in the same run. For example: Configuring Active Directory authentication (winbind) and creating home directories for users from Active Directory in the same puppet run will fail.

For reference, below is an example of Hiera YAML to use this with this shell script. It's not exactly copy/paste. Just use it for inspiration.

```
# SET HIERA VARIABLES HERE
# Note: The value for 'homedirs::path' depends on how you configured smb.conf

homedirs::path: '/home/MY_DOMAIN' # Wishlist item: This should be dynamically read on a per-user basis (i.e. getent passwd Username)
homedirs::group: 'domain users'
```

```
exec:
# This is required as a workaround to this bug:
# https://tickets.puppetlabs.com/browse/PUP-3204 
 'chown_winbind_homedirs.sh':
  command: '/opt/chown_winbind_homedirs.sh/chown_winbind_homedirs.sh'
  refreshonly: true
```

```
file:
 "%{hiera('homedirs::path')}":
  ensure: directory
  
  # NOTE: "myUser" lives in Active Directory
"%{hiera('homedirs::path')}/myUser":
  ensure: directory
  recurse: true
  replace: false
  source: '/etc/skel'
  source_permissions: ignore
  notify: 'Exec[chown_winbind_homedirs.sh]'
```

```
ssh_authorized_key:
 'myUser':
  user: 'myUser'
  key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC5KW/FQldC3gdrSeNuyq63SqYOwT56t6xZ6O/j6n6CPnVFQfuvzWQIf1lyV22SxS2FNI7R0fInhmjVaCx4Gwx3Iouh7vY6ABD4u4X'
  type: 'ssh-rsa'
  require: 'Exec[chown_winbind_homedirs.sh]'
```
