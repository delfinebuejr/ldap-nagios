#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use Config::Simple;
use lib '/var/www/utils';
use Data::Dumper;
use LDAPuser;

my $q = CGI->new;

if($q->param){

#if(1) {
    my $targetUser = $q->param('user_id');
#    my $targetUser = "nnit-dfie1";
    
    my $config = '/var/www/utils/app.conf';
   
    my $cfg = new Config::Simple($config);

    my $connstring = $cfg->param('connstring');
    my $ldapUserBase = $cfg->param('ldapUserBase');
    my $ldapGroupBase = $cfg->param('ldapGroupBase');

#    print "connstring: $connstring\nldapUserBase: $ldapUserBase\nldapGroupBase: $ldapGroupBase\n";
   
    my $objldapuser = LDAPuser->new();

    $objldapuser->search_user( $targetUser, $connstring, $ldapUserBase, $ldapGroupBase );    

#    print Dumper($objldapuser);

    if ($objldapuser->get_dn) {           # if a user was found in ldap create an equivalent nagios contact object
   
    my %hash = (
                 fname => $objldapuser->get_fname,
                 lname => $objldapuser->get_lname,
                 email => $objldapuser->get_email,
                 cn    => $objldapuser->get_cn,
                 uid   => $objldapuser->get_uid,
                 dn    => $objldapuser->get_dn,
                 groupMembership => $objldapuser->get_groupMembership
               );

        print 
            $q->header,
            $q->start_html(),
            $q->h1( $objldapuser->get_dn . " found " ),
            $q->table({ -border => 1, -cellpadding => 3 },
                      map { $q->Tr( $q->td( $_ ), $q->td( $hash{$_}) ) } keys %hash
                     ),

            $q->start_form( -action => '/cgi-bin/util_nagconfig.pl' );

                     for (keys %hash) {
                         print $q->hidden( -name => '$_', -value => $hash{$_} )
                     }

        print
                     $q->submit( -name => 'submit', -value => 'add' ),
                     $q->submit( -name => 'submit', -value => 'back'),

            $q->end_form(),
            $q->end_html;

    }
    else{
        print
            $q->header,
            $q->start_html(),
            $q->h1( "$targetUser does not exist in LDAP " ),
            $q->end_html;
    }
}
else{
    print
            $q->header,
            $q->start_html(),
            $q->h1( " Username required for query " ),
            $q->end_html;
}
