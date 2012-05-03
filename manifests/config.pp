class gitolite::config {
    include ldap_users
    Ssh_Authorized_Key <| user == 'gitolite' |> { notify => Exec['refresh-authkeys'] }

    # Default file permissions
    File {
        owner => "$gitolite::user",
        group => "$gitolite::group",
        mode => 0600,
    }

    file {
        "gitolite.conf":
            ensure => present,
            path => "$gitolite::root/.gitolite/conf/gitolite.conf",
            content => template("gitolite/gitolite.conf.erb"),
            notify => Exec["update-conf"];

        "gitweb.conf":
            ensure => present,
            path => "/etc/gitweb.conf",
            mode => 0644,
            content => template("gitolite/gitweb.conf.erb");

        "gitolite.rc":
            ensure => present,
            path => "$gitolite::root/.gitolite.rc",
            mode => 0644,
            content => template("gitolite/gitolite.rc.erb");

        "update.secondary":
            ensure => present,
            path => "$gitolite::root/.gitolite/hooks/common/update.secondary",
            mode => 0755,
            source => "puppet:///modules/gitolite/update.secondary";

        "gitolite-hooks":
            ensure => directory,
            path => "$gitolite::root/.gitolite/hooks/common/update.secondary.d",
            mode => 0755,
            purge => true,
            recurse => true,
            ignore => ".svn",
            source => "puppet:///modules/gitolite/update.secondary.d";

        "gitolite-suexec-wrapper.sh":
            ensure => present,
            path => "/var/www/gitolite-suexec-wrapper.sh",
            mode => 0755,
            source => "puppet:///modules/gitolite/gitolite-suexec-wrapper.sh";

        "gitweb-caching.conf":
            ensure => present,
            path => "/etc/httpd/conf.d/gitweb-caching.conf",
            mode => 0644,
            content => template("gitolite/gitweb.httpd.conf.erb");
    }

    if $ldap == true {
        file {"ldap-group-query.sh":
            ensure => present,
            path => "/usr/local/bin/ldap-group-query.sh",
            mode => 0700,
            content => template("gitolite/ldap-group-query.sh.erb";
        }
    }

    exec {
        "update-conf":
            cwd => "$gitolite::root/.gitolite",
            command => "/usr/bin/gl-compile-conf && gl-setup",
            user => "$gitolite::user",
            environment => ["HOME=$gitolite::root", "GL_BINDIR=/usr/bin", "GL_RC=$gitolite::root/.gitolite.rc"],
            refreshonly => true;

        "refresh-authkeys":
            cwd => "$gitolite::root/",
            command => "/usr/bin/gl-setup-authkeys -batch $gitolite::root/keys/",
            user => "$gitolite::user",
            environment => "HOME=$gitolite::root",
            refreshonly => true;
    }
}
