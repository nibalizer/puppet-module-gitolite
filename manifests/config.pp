class gitolite::config {
#    include ldap_users::com
#    include ldap_users::net
#    include ldap_users::org
#    include ldap_users::logins
#    Ssh_Authorized_Key <| user == 'gitolite' |> { notify => Exec['refresh-authkeys'] }

    # Default file permissions
    File {
        owner => $gitolite::user,
        group => $gitolite::group,
        mode  => 0600,
    }

    file {
        $gitolite::root:
            ensure  => directory,
            path    => $gitolite::root,
            mode    => '0644';

        'gitweb.conf':
            ensure  => present,
            path    => '/etc/gitweb.conf',
            mode    => '0644',
            content => template('gitolite/gitweb.conf.erb');

        'gitolite.rc':
            ensure  => present,
            path    => "$gitolite::root/.gitolite.rc",
            mode    => '0644',
            require => File[$gitolite::root],
            content => template('gitolite/gitolite.rc.erb');

        'gitolite-confdir':
            ensure => directory,
            mode   => '0755',
            path   => "$gitolite::root/.gitolite";

        'hooks':
            ensure  => directory,
            path    => "$gitolite::root/.gitolite/hooks",
            mode    => '0755',
            require => File[$gitolite::root];

        'hooks-common':
            ensure  => directory,
            path    => "$gitolite::root/.gitolite/hooks/common",
            require => File['hooks'],
            mode    => '0755';

        'update.secondary':
            ensure  => present,
            path    => "$gitolite::root/.gitolite/hooks/common/update.secondary",
            mode    => '0755',
            require => File['hooks-common'],
            source  => 'puppet:///modules/gitolite/update.secondary';

        'gitolite-hooks':
            ensure  => directory,
            path    => "$gitolite::root/.gitolite/hooks/common/update.secondary.d",
            mode    => '0755',
            purge   => true,
            recurse => true,
            ignore  => '.svn',
            require => File['hooks-common'],
            source  => 'puppet:///modules/gitolite/update.secondary.d';

        'gitolite-suexec-wrapper.sh':
            ensure => present,
            path   => '/var/www/gitolite-suexec-wrapper.sh',
            mode   => '0755',
            source => 'puppet:///modules/gitolite/gitolite-suexec-wrapper.sh';

        'gitweb-caching.conf':
            ensure  => present,
            path    => '/etc/httpd/conf.d/gitweb-caching.conf',
            mode    => '0644',
            content => template('gitolite/gitweb.httpd.conf.erb');

        'gitweb-caching':
            ensure  => directory,
            path    => '/var/www/gitweb-caching',
            mode    => '0755',
            recurse => true;

        'gl-conf-dir':
            ensure  => directory,
            path    => "$gitolite::root/.gitolite.conf.d",
            recurse => true,
            mode    => '0755';

        'concat-gl-conf':
            ensure  => present,
            path    => '/usr/local/bin/concat-gl-conf',
            content => template('gitolite/concat-gl-conf.erb'),
            mode    => '0755';
    }

    if $gitolite::ldap == true {
        file {'ldap-group-query.sh':
            ensure => present,
            path   => '/usr/local/bin/ldap-group-query.sh',
            mode   => '0700',
            source => 'puppet:///modules/gitolite/ldap-group-query.sh';
        }
    }

    exec {
        'generate-repo-list':
            cwd         => "$gitolite::root/.gitolite.conf.d",
            command     => '/usr/local/bin/concat-gl-conf',
            user        => $gitolite::user,
            require     => [File['concat-gl-conf'], File['gl-conf-dir']],
            environment => "HOME=$gitolite::root",
            notify      => Exec['update-conf'],
            refreshonly => true;
        'update-conf':
            cwd         => "$gitolite::root/.gitolite",
            command     => '/usr/bin/gl-compile-conf',
            user        => $gitolite::user,
            environment => ["HOME=$gitolite::root",
                            'GL_BINDIR=/usr/bin',
                            "GL_RC=$gitolite::root/.gitolite.rc"],
            refreshonly => true;

        'refresh-authkeys':
            cwd         => $gitolite::root,
            command     => "/usr/bin/gl-setup-authkeys -batch $gitolite::root/keys/",
            user        => $gitolite::user,
            environment => "HOME=$gitolite::root",
            refreshonly => true;
    }
}
