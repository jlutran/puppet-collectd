# See http://collectd.org/documentation/manpages/collectd.conf.5.shtml#plugin_processes
class collectd::plugin::processes (
  $ensure                          = 'present',
  $order                           = 10,
  $interval                        = undef,
  Optional[Array] $processes       = undef,
  Optional[Array] $process_matches = undef,
) {

  include ::collectd

  collectd::plugin { 'processes':
    ensure   => $ensure,
    order    => $order,
    interval => $interval,
  }

  concat { "${collectd::plugin_conf_dir}/processes-config.conf":
    ensure         => $ensure,
    mode           => $collectd::config_mode,
    owner          => $collectd::config_owner,
    group          => $collectd::config_group,
    notify         => Service[$collectd::service_name],
    ensure_newline => true,
  }
  concat::fragment { 'collectd_plugin_processes_conf_header':
    order   => '00',
    content => '<Plugin processes>',
    target  => "${collectd::plugin_conf_dir}/processes-config.conf",
  }
  concat::fragment { 'collectd_plugin_processes_conf_footer':
    order   => '99',
    content => '</Plugin>',
    target  => "${collectd::plugin_conf_dir}/processes-config.conf",
  }

  if $processes {
    collectd::plugin::processes::process { $processes : }
  }
  if $process_matches {
    $process_matches_resources = collectd_convert_processmatch($process_matches)
    $defaults = { 'ensure' => $ensure }
    create_resources(
      collectd::plugin::processes::processmatch,
      $process_matches_resources,
      $defaults
    )
  }
}
