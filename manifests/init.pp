# Class: gitolite
#
# This module manages gitolite
#
# Parameters:
#   root: Directory to store root filesystem (default: /var/lib/gitolite)
#   user: User to run gitolite as (default: gitolite)
#   group: Group to run gitolite as (default: gitolite)
#
#   LDAP-centric parameters
#   ldap: Whether to use ldap to manage users (default: false)
#   ldap_host: LDAP's bind host (default: '')
#   ldap_user: LDAP's bind username (default: '')
#   ldap_pass: LDAP's bind password (default: '')
#   ldap_searchbase: LDAP's searchbase (default: '')
#
# Actions:
#
#   Installs, configures, and manages a gitolite instance
#
# Requires:
#
# Sample Usage:
#
#   class { "gitolite":
#       $root      => '/repo',
#       $ldap      => true,
#       $ldap_host => 'localhost',
#       $ldap_user => 'gitolite',
#       $ldap_pass => 'hunter2'
#       $ldap_searchbase => 'ou=groups,dc=mycompany'
#   }
#
# [Remember: No empty lines between comments and class definition]
class gitolite ($root='/var/lib/gitolite',
                $user='gitolite',
                $group='gitolite',
                $ldap=false,
                $ldap_host='',
                $ldap_user='',
                $ldap_pass='',
                $ldap_searchbase=''
    ) {

    if $ldap == true {
        $no_setup_authkeys = 1
        $enable_external_membership_program = true
        if $ldap_pass == '' {
            fail('You probably need a bind password (ldap_pass param)')
        }
        if $ldap_user == '' {
            fail('You probably need a bind username (ldap_user param)')
        }
        if $ldap_host == '' {
            fail('You probably need a bind hostname (ldap_host param)')
        }
        if $ldap_searchbase == '' {
            fail('You probably need a bind search base (ldap_searchbase param)')
        }
    } else {
        $no_setup_authkeys = 0
        $enable_external_membership_program = false
    }


    Yumrepo <| title == 'epel' |>
    Yumrepo <| title == 'mozilla' |>

    #### This is unnecessary with other mozilla classes ####
    #yumrepo { 'epel':
    #    mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch",
    #    enabled    => 1,
    #    gpgcheck   => 0,
    #}

    class {
        'gitolite::user':
            before => Class['gitolite::packages'];
        'gitolite::packages':
            before => Class['gitolite::config'];
        'gitolite::config':;
    }
}

