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

my $objldapuser = LDAPuser->new();

$objldapuser->search_user_debug( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );
#$objldapuser->search_user( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );

print Dumper($objldapuser);
