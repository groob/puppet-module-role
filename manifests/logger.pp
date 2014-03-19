#
# Configures logstash server
#
class role::logger {
  include profile::common
  include profile::logstash
  include profile::elasticsearch
  include profile::kibana

  # Firewall rules
  include profile::firewall
  Firewall {
    require => Class['profile::firewall::pre'],
    before  => Class['profile::firewall::post'],
    chain   => 'INPUT',
    proto   => 'tcp',
    action  => 'accept',
  }
  firewall { '210 nat deny all':
    proto  => 'all',
    action => 'drop',
  }
}

