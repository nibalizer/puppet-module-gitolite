define gitolite::repo ($path,
                       $owner='Mozilla',
                       $desc='This repo needs a description',
                       $order='999',
                       $rwplus='',
                       $rw='',
                       $r=''
                       $hooks=[]) {
    file {"${title}":
        ensure  => present,
        path    => "${path}/${order}-${title}",
        content => template('gitolite/repo.pp'),
        mode    => '0644',
        notify  => Exec['gitolite::generate-repo-list']
    }
}
