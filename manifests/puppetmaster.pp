#
# The puppetmaster role configures the puppetmaster and puppetdb
#
class role::puppetmaster (
  $r10k_environments_dir    = '/etc/puppet/environments',
  $r10k_environments_remote = 'https://github.com/groob/puppet-environments.git',
  $r10k_hiera_dir    = '/etc/puppet/hiera',
  $r10k_hiera_remote = '/opt/hieradata.git',
  $srv_root         = '/var/seteam-files',
) {
  include git
  include profile::common
  # PuppetDB config
  class { 'puppetdb':
    listen_address      => '0.0.0.0',
    ssl_listen_address  => '0.0.0.0',
  }
  class { 'puppetdb::master::config':
    puppet_service_name => 'apache2',
  }

  file { '/etc/puppet/hiera.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('role/puppetmaster/hiera.yaml.erb'),
  }

  ini_setting { 'puppet_hieraconfig':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
    setting => 'hiera_config',
    value   => '/etc/puppet/hiera.yaml',
  }

}
