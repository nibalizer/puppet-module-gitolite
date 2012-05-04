define gitolite::repo ($owner='Mozilla',
                       $desc='This repo needs a description',
                       $order='999',
                       $rwplus='',
                       $rw='',
                       $r='',
                       $hooks=[]) {
    file {"${title}":
        ensure  => present,
        path    => "${gitolite::root}/.gitolite.conf.d/${order}-${title}",
        content => template('gitolite/repo.erb'),
        mode    => '0644',
        notify  => Exec["generate-repo-list-${name}"]
    }

    exec {
        "generate-repo-list-${name}":
            cwd => "$gitolite::root/.gitolite.conf.d",
            command => '/usr/local/bin/concat-gl-conf',
            user => $gitolite::user,
            require => [File['concat-gl-conf'], File['gl-conf-dir']],
            environment => "HOME=$gitolite::root",
            notify => Exec['update-conf'],
            refreshonly => true;
        "update-conf-${name}":
            cwd => "$gitolite::root/.gitolite",
            command => '/usr/bin/gl-compile-conf',
            user => $gitolite::user,
            environment => ["HOME=$gitolite::root",
                            'GL_BINDIR=/usr/bin',
                            "GL_RC=$gitolite::root/.gitolite.rc"],
            refreshonly => true;

    }
}
