#
# Configures logstash server
#
class role::logger {
  include profile::common
  include profile::logstash
}

