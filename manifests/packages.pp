class gitolite::packages {
    $gitwebpkg = $operatingsystem? {
        "CentOS" => "gitweb",
        "RedHat" => "gitweb-caching"
    }

    package {
        ["gitolite", $gitwebpkg]:
            ensure => installed,
            require => Yumrepo["epel"];
    }

   
}
