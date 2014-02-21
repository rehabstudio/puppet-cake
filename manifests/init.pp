# Simple class that pulls down the cake core and registers it in PATH. Also creates some preliminary files and folders, including the database.php and logs
class cakeCore {

    exec { 'Download CakePHP Core':
        command => "git clone -b ${cakeTag} https://github.com/cakephp/cakephp.git ${cakeRoot}",
        creates => $cakeRoot,
        require => Package['git-core'];
    }

    file { 
      'Install cake project directories':
        path => [
            "${appRoot}/Config",
            "${appRoot}/tmp",
            "${appRoot}/tmp/logs",
            "${appRoot}/tmp/cache",
            "${appRoot}/tmp/cache/models",
            "${appRoot}/tmp/cache/persistent",
            "${appRoot}/tmp/cache/views"
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
        path => $cakeRoot,
        recurse => true,
        require => Exec['Download CakePHP Core']
    }

    file_line { 'Adding CakePHP Core to Path':
        path => '/home/vagrant/.bashrc',
        line => "export PATH=${cakeRoot}/lib/Cake/Console:\$PATH # Adding CakePHP core to path.",
        require => Exec['Download CakePHP Core']
    }

    file { 'Ensure Database Configuration Present':
        ensure => present,
        path => "${appRoot}/Config/database.php",
        owner   => 'vagrant', 
        group => 'vagrant',
        content => template("cakecore/database.erb"),
        replace => no
    }

}
