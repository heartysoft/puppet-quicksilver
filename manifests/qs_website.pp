#
define quicksilver::qs_website($environment, $publishroot, $version, $sitename=$title) {
    $expected_version_file = "C:\\quicksilver_installed\\${sitename}.txt"

    exec { "quicksilver_qs_website_${sitename}_should_install":
        provider=> powershell,
        unless => "if((test-path \"$expected_version_file\") -and (\"${environment}-${version}\" -eq (get-content \"$expected_version_file\").Trim())){exit 0} else {exit 1}",
        command => "exit 0",
    }
    ~>
    file { ["C:/quicksilver_installers/$sitename",
            "C:/quicksilver_installers/$sitename/$version"]:
        ensure => directory
    }
    ~>
    file { "C:/quicksilver_installers/$sitename/${version}.zip":
        source => "$publishroot/$sitename/${version}.zip",
        ensure => present
    }
    ~>
    exec { "quicksilver_qs_website_${sitename}_extract":
        command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$sitename/${version}/')).Copyhere(\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$sitename/${version}.zip')).items(), 16)",
        provider => powershell,
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_website_${sitename}_should_install'],                   
    }
    ~>
    exec { "quicksilver_qs_website_${sitename}_install":
        command => "C:/quicksilver_installers/$sitename/$version/install.bat $environment /Y",
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_website_${sitename}_should_install'],                      
    }
    ~>
    exec { "version file for qs_website ${sitename}" :
        refreshonly => true,
        provider => powershell,        
        command => "\"${environment}-${version}\" | out-file \"$expected_version_file\" -Force",
    }
}
