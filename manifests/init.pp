# Simple class that pulls down the cake core and registers it in PATH. Also creates some preliminary files and folders, including the database.php and logs
class cakeCore {

    exec { 'Download CakePHP Core':
        command => "git clone -b ${settings::ymlconfig[cake][repoTag]} https://github.com/cakephp/cakephp.git ${ymlconfig[cake][corePath]}",
        creates => $settings::ymlconfig['cake']['corePath'],
        require => Package['git-core'];
    }

    file { 
      'Install cake project directories':
        path => [
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/Config",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp/logs",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp/cache",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp/cache/models",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp/cache/persistent",
            "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/tmp/cache/views"
        ],
        ensure => directory,
        mode => 0777,
        recurse => true
    }

    file { 'Changing CakePHP Core Permissions':
        ensure => directory,
        group => 'vagrant',
        mode => 0755,
        owner => 'vagrant',
        path => $settings::ymlconfig['cake']['corePath'],
        recurse => true,
        require => Exec['Download CakePHP Core']
    }

    file_line { 'Adding CakePHP Core to Path':
        path => '/home/vagrant/.bashrc',
        line => "export PATH=${settings::ymlconfig[cake][corePath]}/lib/Cake/Console:\$PATH # Adding CakePHP core to path.",
        require => Exec['Download CakePHP Core']
    }

    file { 'Ensure Database Configuration Present':
        ensure => present,
        path => "${settings::ymlconfig[env][docRoot]}${settings::ymlconfig[env][siteRoot]}/Config/database.php",
        owner   => 'vagrant', 
        group => 'vagrant',
        content => template("cakecore/database.erb"),
        replace => no
    }

}

class { 'cakeCore':
    
}
