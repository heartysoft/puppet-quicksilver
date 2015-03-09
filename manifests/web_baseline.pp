#
define quicksilver::web_baseline($msdeploy_path) {
    $msdeploy_file = basename($msdeploy_path)

    windowsfeature { 'IIS':
      feature_name => [
        'Web-Static-Content',
        'Web-Default-Doc',
        'Web-Http-Errors',
        'Web-Http-Redirect',
        'Web-Http-Logging',
        'Web-Log-Libraries',
        'Web-Request-Monitor',
        'Web-Filtering',
        'Web-Stat-Compression',
        'Web-Mgmt-Console',
        'Web-Net-Ext',
        'Web-ISAPI-Filter',
        'Web-ISAPI-Ext',
        'Web-Asp-Net',
      ]
    }
    ->
    file { "C:/packages/$msdeploy_file":
        source => $msdeploy_path,
        source_permissions => ignore,
        ensure => present,
    }
    ->
    package { 'Microsoft Web Deploy 3.5':
        ensure => present,
        source => "C:/packages/$msdeploy_file",
        install_options => [ '/q', '/norestart' ],
    }
    ~>
    exec { 'regiis':
        command => "C:\\windows\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_regiis.exe -i",
        refreshonly => true,    
    }
}