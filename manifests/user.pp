class gitolite::user {

    User["gitolite"] -> File["keydir"]

    file { "keydir":
        path => "$gitolite::root/keys",
        ensure => directory,
        require => User["gitolite"],
    }
    group { "gitolite":
        ensure => present,
        gid => 1055; # We need something > 500 so suexec will run
    }
    user { "gitolite":
        ensure => present,
        comment => "git repository hosting",
        shell => "/bin/sh",
        home => $gitolite::root,
        uid => 1055; # We need something > 500 so suexec will run
    }
}
