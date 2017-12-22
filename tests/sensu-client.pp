node default {

  $filters = {
    'offhours'          => {
      'attributes'      => {
        'client'        => {
          'environment' => 'production',
        },
      },
      'when'    => {
        'days'  => {
          'all' => [
            {
              'begin' => '2:00 AM',
              'end'   => '1:00 AM',
            },
          ],
        },
      },
    },
  }

  $filter_defaults = {
    'when'    => {
      'days'  => {
        'all' => [
          {
            'begin' => '2:00 AM',
            'end'   => '1:00 AM',
          },
        ],
      },
    },
  }

  # Use the internal 192.168.56.* address
  if $facts['networking']['interfaces']['eth1'] != undef {
    $ip = $facts['networking']['interfaces']['eth1']['ip']
  } elsif $facts['networking']['interfaces']['enp0s8'] != undef {
    $ip = $facts['networking']['interfaces']['enp0s8']['ip']
  } else {
    $ip = $facts['networking']['ip']
  }

  $client_ec2 = {
    'instance-id' => 'i-2102113',
  }
  $client_puppet = {
    'nodename' => $::fqdn,
  }
  $client_chef = {
    'nodename' => $::fqdn,
  }
  $client_servicenow = {
    'configuration_item' => {
      'name' => 'ServiceNow test',
      'os_version' => '16.04',
    },
  }
  class { '::sensu':
    rabbitmq_password => 'correct-horse-battery-staple',
    rabbitmq_host     => '192.168.56.10',
    rabbitmq_vhost    => '/sensu',
    subscriptions     => 'all',
    client_address    => $ip,
    client_ec2        => $client_ec2,
    client_chef       => $client_chef,
    client_puppet     => $client_puppet,
    client_servicenow => $client_servicenow,
    filters           => $filters,
    filter_defaults   => $filter_defaults,
  }

    $metrics = {
      'loadmetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-load.rb --scheme "sensu.metrics.:::shortname:::.load"', },
      'cpumetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-cpu-pcnt-usage.rb --scheme "sensu.metrics.:::shortname:::.cpu"', },
      'netmetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-interface.rb --scheme "sensu.metrics.:::shortname:::.interface"', },
      'netstatmetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-netstat-tcp.rb --scheme "sensu.metrics.:::shortname:::.netstat"', },
      'diskmetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-disk.rb --scheme "sensu.metrics.:::shortname:::.disk"', },
      'diskfree' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-disk-usage.rb --scheme "sensu.metrics.:::shortname:::.df"', },
      'memorymetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-memory.rb --scheme "sensu.metrics.:::shortname:::.memory"', },
      'threadmetrics' => { command => 'PATH=/opt/sensu/embedded/bin/:$PATH metrics-processes-threads-count.rb --scheme "sensu.metrics.:::shortname:::.threads"', },
    }
    # lint:endignore

    $metrics_default = {
        'type'        => 'metric',
        'handlers'    => ['graphite_tcp','graphite_metrictank'],
        'standalone'  => false,
        'subscribers' => 'default',
    }

    create_resources(sensu::check, $metrics, $metrics_default)


}
