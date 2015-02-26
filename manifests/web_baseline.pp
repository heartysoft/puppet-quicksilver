#
define quicksilver::web_baseline($msdeploy_path, $dotnet_version='45') {
    file {'c:\packages':
        ensure => directory
    }
    ->
    class { 'dotnet':
      version => "$dotnet_version",
    }
    ->
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
    package { 'Microsoft Web Deploy 3.5':
        ensure => present,
        source => $msdeploy_path,
        install_options => [ '/q', '/norestart' ],
    }
    ~>
    exec { 'regiis':
        command => "C:\\windows\\Microsoft.NET\\Framework64\\v4.0.30319\\aspnet_regiis.exe -i",
        refreshonly => true,    
    }

    reboot { 'after':
        subscribe       => Class['dotnet'],
    }
}