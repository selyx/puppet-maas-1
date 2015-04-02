# == Define: maas::superuser
#
# Creates the mass admin user account it
# stores that user account in 
#
# === Authors
#
# Peter J. Pouliot <peter@pouliot.net>
#
# === Copyright
#
# Copyright 2015 Peter J. Pouliot <peter@pouliot.net>, unless otherwise noted.
#
define maas::superuser ( $password, $email ) { 

  validate_string($name)
  validate_string($password)
  validate_string($email)
  ## Command to Create a SuperUser in MAAS
  exec{"create-superuser-$name":
    command   => "/usr/sbin/maas-region-admin createadmin --username=${$name} --email=${email} --password=${passwd}",
    cwd       => '/etc/maas/.puppet/'
    logoutput => true,
    unless      => "/usr/sbin/maas login ${maas::profile_name} ${maas::server_url} < /etc/maas/.puppet/su-${name}.maas ",
    notify    => Exec["get-api-key-superuser-account-$name"],
  }

  ## Command to get the MAAS User's Key
  exec{"new_get-api-key-superuser-account-$name":
    command     => "/usr/sbin/maas-region-admin apikey ${maas::profile_name} --username ${name} > /etc/maas/.puppet/su-${name}.maas",
    creates     => "/etc/maas/.puppet/su-${name}.maas",
    cwd         => '/etc/maas/.puppet/'
    unless      => "/usr/sbin/maas login ${maas::profile_name} ${maas::server_url} < /etc/maas/.puppet/su-${name}.maas ",
    refreshonly => true,
    logoutput   => true,
    notify      => Exec["login-superuser-with-api-key-$name"],
  }

  ## Command to Login to the MAAS profile using the api-key
  warning("superuser: ${name} login test")
  exec{"login-superuser-with-api-key-$name":
    command     => "/usr/sbin/maas login ${maas::profile_name} ${maas::server_url} < /etc/maas/.puppet/su-${name}.maas ",
    cwd         => '/etc/maas/.puppet'
    refreshonly => true,
    logoutput   => true,
    notify      => exec["logout-superuser-with-api-key-$name"],
  }
  ## Command to Log out profile and flush creds
  warning("superuser: ${name} logout and flush credentials!")
  exec{"logout-superuser-with-api-key-$name":
    command     => "/usr/sbin/maas refresh",
    cwd         => '/etc/maas/.puppet'
    refreshonly => true,
    logoutput   => true,
  }
}
