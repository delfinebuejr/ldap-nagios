#!/usr/bin/perl

# Searches openldap for a user account that matches $targetUser.
# instantiates a NagiosConfigObject which is used for validating
# if the target user exists in 

use warnings;
use strict;
use Carp qw(croak);
use Data::Dumper;
use lib '../lib';

use LDAPuser;
use NagiosContact;
use NagiosConfigObjects;
use SVN::Client;
use Config::Simple;


my $config = '../config/app.conf';

my $cfg = new Config::Simple($config);

my $connstring = $cfg->param('connstring');
my $ldapUserBase = $cfg->param('ldapUserBase');
my $ldapGroupBase = $cfg->param('ldapGroupBase');

my $targetUser = 'nnit-dfie1';
my $configFile = $cfg->param('configFile');
my $objectType = $cfg->param('objectType');

my $svn_local_workspace = $cfg->param('svn_local_workspace');;
my $svn_url = $cfg->param('svn_url');
my $svn_username = $cfg->param('svn_username');
my $svn_password = $cfg->param('svn_password');

my $contactGroup = $cfg->param('contactGroup');
my $contactType = $cfg->param('contactType');

my $objldapuser = LDAPuser->new();

#$objldapuser->search_user_debug( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );
$objldapuser->search_user( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );

print Dumper($objldapuser);

if ($objldapuser->get_dn) {           # if a user was found in ldap create an equivalent nagios contact object
    print "true\n";

### SERIALIZE THE LDAP INFORMATION
    
    my $contact = NagiosContact->new({
                                   fname => $objldapuser->get_fname,
                                   lname => $objldapuser->get_lname,
                                   email => $objldapuser->get_email,
                                   contactGroup => $contactGroup,
                                   contactType => $contactType
                                });
    
    
### PREPARE THE LOCAL WORKSPACE

    my $client = new SVN::Client(
      auth => [
          SVN::Client::get_simple_provider(),
          SVN::Client::get_simple_prompt_provider(\&simple_prompt,2),
          SVN::Client::get_username_provider()
      ]);

### CHECKOUT CONFIG FILE

    if ( -e $svn_local_workspace ) {

        unlink glob "$svn_local_workspace/*";

    }

    $client->checkout($svn_url,$svn_local_workspace,'HEAD',1);
    
### CREATE CONTACTS FILE OBJECT

    my $objconfigfile = NagiosConfigObjects->new({
                                              file => "$svn_local_workspace/$configFile",
                                              filter => $objectType
                                             });

    for(my $i = 0; $i <= $objconfigfile->get_count -1 ; $i++) {            # run the fullName against the config file objects to ensure that it does not exist yet
        print Dumper($objconfigfile->get_allobjects->[$i]->{attribute}->{contact_name});

        if ($contact->get_fullName eq $objconfigfile->get_allobjects->[$i]->{attribute}->{contact_name}) {
            croak( $contact->get_fullName . " nagios contact already exists. Nothing to do.");
        }
    }

### WRITE CONTACT TO FILE IF IT DOES NOT EXISTS 

    print "Adding " . $contact->get_fullName . " to $configFile\n";

    $objconfigfile->write_object($contact->create_nagiosContact);

### CHECKIN UPDATED FILE

    $client->commit("$svn_local_workspace/$configFile",0);
   
}
else{
   print "User does not exist in LDAP server!\n";
}

# FUNCTION DEFINITIONS

sub simple_prompt {
    my ($cred, $realm, $default_username, $may_save, $pool) = @_;

    chomp($svn_username);
    $cred->username($svn_username);
    chomp($svn_password);
    $cred->password($svn_password);
}

