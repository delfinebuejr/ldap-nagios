#!/usr/bin/perl

use warnings;
use strict;
use Carp qw(croak);
use Data::Dumper;
use lib 'lib';

use LDAPuser;
use NagiosContact;
use NagiosConfigObjects;

my $connstring = 'localhost,cn=manager,redhat';
my $ldapUserBase = 'ou=Users,dc=local,dc=lan';
my $ldapGroupBase = 'ou=Group,dc=local,dc=lan';
my $targetUser = 'nnit-dfie1';

my $contactGroup = 'nnit-admins';
my $contactType = 'admins';

my $objldapuser = LDAPuser->new();
my $objconfigfile = NagiosConfigObjects->new({
                                              file => '/var/www/cgi-bin/contacts.cfg',
                                              filter => 'contact'
                                             });

#$objldapuser->search_user_debug( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );
$objldapuser->search_user( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );

print Dumper($objldapuser);

if ($objldapuser->get_dn) {           # if a user was found in ldap create an equivalent nagios contact object
    print "true\n";

    my $contact = NagiosContact->new({
                                   fname => $objldapuser->get_fname,
                                   lname => $objldapuser->get_lname,
                                   email => $objldapuser->get_email,
                                   contactGroup => $contactGroup,
                                   contactType => $contactType
                                });
    
    for(my $i = 0; $i <= $objconfigfile->get_count -1 ; $i++) {            # run the fullName against the config file objects to ensure that it does not exist yet
        print Dumper($objconfigfile->get_allobjects->[$i]->{attribute}->{contact_name});

        if ($contact->get_fullName eq $objconfigfile->get_allobjects->[$i]->{attribute}->{contact_name}) {
            croak( $contact->get_fullName . "already exists");
        }
    }

    print $contact->get_fullName . " does not exist yet!\n";

    $objconfigfile->write_object($contact->create_nagiosContact);

    

}
else{
   print "false\n";
}

