#
# Configures logstash server
#
class role::logger {
  include profile::common
  include profile::logstash
  include profile::elasticsearch
  include profile::kibana
  include profile::firewall
  Firewall {
    require => Class['profile::firewall::pre'],
    before  => Class['profile::firewall::post'],
    chain   => 'INPUT',
    proto   => 'tcp',
    action  => 'accept',
  }
  firewall { '110 apache allow all':       dport  => '80';    }
}

