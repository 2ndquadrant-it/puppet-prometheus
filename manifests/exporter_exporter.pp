class prometheus::exporter_exporter (
  String[1] $download_extension,
  String[1] $download_url_base,
  Array[String[1]] $extra_groups,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $user,
  String[1] $version,
  String $config_file                           = '/etc/exporter_exporter.yaml',
  Boolean $purge_config_dir                     = true,
  Boolean $restart_on_change                    = true,
  Boolean $service_enable                       = true,
  Stdlib::Ensure::Service $service_ensure       = 'running',
  String[1] $service_name                       = 'exporter_exporter',
  Prometheus::Initstyle $init_style             = $facts['service_provider'],
  String[1] $install_method                     = $prometheus::install_method,
  Boolean $manage_group                         = true,
  Boolean $manage_service                       = true,
  Boolean $manage_user                          = true,
  String[1] $os                                 = downcase($facts['kernel']),
  Optional[String] $download_url                = undef,
  String $config_mode                           = $prometheus::config_mode,
  String[1] $arch                               = $prometheus::real_arch,
  String[1] $bin_dir                            = $prometheus::bin_dir,
  Boolean $export_scrape_job                    = false,
  Stdlib::Port $scrape_port                     = 9998,
  Optional[Hash] $scrape_job_labels             = undef,
  Hash $modules                                 = {},
  Boolean $ssl                                  = false,
  String $listen_ssl                            = '',
  String $cert_path                             = '',
  String $key_path                              = '',
) inherits prometheus {

  $release = "v${version}"

  $real_download_url = pick($download_url, "${download_url_base}/download/${release}/${package_name}-${version}.${os}-${arch}.${download_extension}")

  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  if $ssl {
    $ssl_options = "--web.tls.listen-address=${listen_ssl} --web.tls.cert=${cert_path} --web.tls.key=${key_path}"
  } else {
    $ssl_options = ''
  }

  $options = "--config.file=${config_file} ${ssl_options}"

  file { $config_file:
    ensure  => present,
    owner   => 'root',
    group   => $group,
    mode    => $config_mode,
    content => template('prometheus/exporter_exporter.yaml.erb'),
    notify  => $notify_service,
  }

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    real_download_url  => $real_download_url,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
  }
}
