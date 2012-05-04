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
        notify  => Exec['gitolite::config::generate-repo-list']
    }
}
