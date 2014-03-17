#
# The puppetmaster role configures the puppetmaster and puppetdb
#
class role::puppetmaster (
  $r10k_environments_dir    = '/etc/puppet/environments',
  $r10k_environments_remote = 'https://github.com/groob/puppet-environments.git',
  $srv_root                 = '/var/seteam-files',
) {
  include git
  # PuppetDB config
  class { 'puppetdb':
    listen_address      => '0.0.0.0',
    ssl_listen_address  => '0.0.0.0',
  }
  class { 'puppetdb::master::config': }

  package { 'r10k':
    ensure   => present,
    provider => gem,
  }

  # Template uses:
  #   - $r10k_environments_dir
  #   - $r10k_environments_remote
  file { '/etc/r10k.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('role/puppetmaster/r10k.yaml.erb'),
  }

  ini_setting { 'puppet_modulepath':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
    setting => 'modulepath',
    value   => "${r10k_environments_dir}/\$environment/modules:/opt/puppet/share/puppet/modules",
  }
  ini_setting { 'puppet_manifest':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
    setting => 'manifest',
    value   => "${r10k_environments_dir}/\$environment/manifests/site.pp"
  }
  ini_setting { 'puppet_hieraconfig':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'main',
    setting => 'hiera_config',
    value   => "${r10k_environments_dir}/production/hiera.yaml"
  }

  Exec {
    path    => '/opt/puppet/bin:/usr/bin:/bin',
    require => [
      Package['r10k'],
      Class['git'],
      File['/etc/r10k.yaml'],
    ],
  }

  exec { 'instantiate_environments':
    command => '/usr/bin/r10k deploy environment',
    creates => $r10k_environments_dir,
  }

}
