#
define quicksilver::qs_website($environment, $publishroot, $version, $sitename=$title) {
    $expected_version_file = "C:\\quicksilver_installed\\${sitename}.txt"

    exec { 'quicksilver_qs_website_should_install':
        provider=> powershell,
        unless => "if((test-path \"$expected_version_file\") -and (\"${environment}-${version}\" -eq (get-content \"$expected_version_file\").Trim())){exit 0} else {exit 1}",
        command => "exit 0",
    }
    ~>
    file { ["C:/quicksilver_installed",
            "C:/quicksilver_installers",
            "C:/quicksilver_installers/$sitename",
            "C:/quicksilver_installers/$sitename/$version"]:
        ensure => directory
    }
    ~>
    file { "C:/quicksilver_installers/$sitename/${version}.zip":
        source => "$publishroot/$sitename/${version}.zip",
        ensure => present
    }
    ~>
    exec { "quicksilver_qs_website_extract":
        command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$sitename/${version}/')).Copyhere(\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$sitename/${version}.zip')).items(), 16)",
        provider => powershell,
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_website_should_install'],                   
    }
    ~>
    exec { "quicksilver_qs_website_install":
        command => "C:/quicksilver_installers/$sitename/$version/install.bat $environment /Y",
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_website_should_install'],                      
    }
    ~>
    exec { "version file" :
        refreshonly => true,
        provider => powershell,        
        command => "\"${environment}-${version}\" | out-file \"$expected_version_file\" -Force",
    }
}
