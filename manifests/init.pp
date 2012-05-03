class gitolite ($root="/var/lib/gitolite",
                $user="gitolite",
                $group="gitolite",
                $repos=[],
                $ldap=false,
                $bindpw=""
    ) {

    if $ldap == true {
        $no_setup_authkeys = 1
        $enable_external_membership_program = true
    } else {
        $no_setup_authkeys = 0
        $enable_external_membership_program = false
    }


    Yumrepo <| title == "epel" |>
    Yumrepo <| title == "mozilla" |>

    #### This is unnecessary with other mozilla classes ####
    #yumrepo { "epel":
    #    mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch",
    #    enabled => 1,
    #    gpgcheck => 0,
    #}

    class {
        'gitolite::user':
            before => Class['gitolite::packages'];
        'gitolite::packages':
            before => Class['gitolite::config'];
        'gitolite::config':;
    }
}
