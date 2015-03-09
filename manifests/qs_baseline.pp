#
define quicksilver::qs_baseline($dotnet_version='45') {
	file { ["C:/quicksilver_installed",
            "C:/quicksilver_installers",
            "C:/packages"] :
        ensure => directory,
    }
    ->
    class { 'dotnet':
      version => "$dotnet_version",
    }

	reboot { 'after':
        subscribe       => Class['dotnet'],
    }
}
