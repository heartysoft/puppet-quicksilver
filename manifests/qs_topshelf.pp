#
define quicksilver::qs_topshelf($environment, $publishroot, $version, $servicename=$title) {
    $expected_version_file = "C:\\quicksilver_installed\\${servicename}.txt"

    exec { 'quicksilver_qs_topshelf_${servicename}_should_install':
        provider=> powershell,
        unless => "if((test-path \"$expected_version_file\") -and (\"${environment}-${version}\" -eq (get-content \"$expected_version_file\").Trim())){exit 0} else {exit 1}",
        command => "exit 0",
    }
    ~>
    file { ["C:/quicksilver_installers/$servicename",
            "C:/quicksilver_installers/$servicename/$version"]:
        ensure => directory
    }
    ~>
    file { "C:/quicksilver_installers/$servicename/${version}.zip":
        source => "$publishroot/$servicename/${version}.zip",
        ensure => present
    }
    ~>
    exec { "quicksilver_qs_topshelf_${servicename}_extract":
        command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$servicename/${version}/')).Copyhere(\$sh.namespace((Convert-Path 'C:/quicksilver_installers/$servicename/${version}.zip')).items(), 16)",
        provider => powershell,
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_topshelf_${servicename}_should_install'],                   
    }
    ~>
    exec { "quicksilver_qs_topshelf_${servicename}_install":
        command => "C:/quicksilver_installers/$servicename/$version/install.bat $environment",
        refreshonly => true,
        subscribe => Exec['quicksilver_qs_topshelf_${servicename}_should_install'],                      
        logoutput => true,
    }
    ~>
    exec { "version file for qs_topshelf ${servicename}" :
        refreshonly => true,
        provider => powershell,        
        command => "\"${environment}-${version}\" | out-file \"$expected_version_file\" -Force",
    }
}
