#$nginxCakePath = "PHP_VALUE include_path=.:/usr/share/php:/usr/share/pear:${ymlconfig[cake][corePath]}"

class cakeCore {

    exec { 'Download CakePHP Core':
        command => "git clone -b ${ymlconfig[cake][repoTag]} https://github.com/cakephp/cakephp.git ${ymlconfig[cake][corePath]}",
        creates => $ymlconfig['cake']['corePath'],
        require => Package['git-core'];
    }

    file { [
        "${siteRoot}/Config",
        "${siteRoot}/tmp",
        "${siteRoot}/tmp/logs",
        "${siteRoot}/tmp/cache",
        "${siteRoot}/tmp/cache/models",
        "${siteRoot}/tmp/cache/persistent",
        "${siteRoot}/tmp/cache/views"
    ]:
        ensure => directory,
        mode => 0777,
        recurse => true
    }

    file { 'Changing CakePHP Core Permissions':
        ensure => directory,
        group => 'vagrant',
        mode => 0755,
        owner => 'vagrant',
        path => $ymlconfig['cake']['corePath'],
        recurse => true,
        require => Exec['Download CakePHP Core']
    }

    file_line { 'Adding CakePHP Core to Path':
        path => '/home/vagrant/.bashrc',
        line => "export PATH=${ymlconfig[cake][corePath]}/lib/Cake/Console:\$PATH # Adding CakePHP core to path.",
        require => Exec['Download CakePHP Core']
    }

    file { 'Ensure Database Configuration Present':
        ensure => present,
        path => "${siteRoot}/Config/database.php",
        owner   => root, group => root,
        content => template("cakecore/database.erb"),
        replace => no
    }

}

class { 'cakeCore':
    
}
