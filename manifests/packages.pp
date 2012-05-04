class gitolite::packages {
    $gitwebpkg = $::operatingsystem? {
        'CentOS' => 'gitweb',
        'RedHat' => 'gitweb-caching'
    }

    package {
        ['gitolite', $gitolite::gitwebpkg]:
            ensure  => installed,
            require => Yumrepo['epel'];
    }
}
