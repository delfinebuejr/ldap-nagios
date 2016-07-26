#!/usr/bin/perl

use strict;
use warnings;

use CGI;

my $q = CGI->new;

    print 
        $q->header,
        $q->start_html("CGI.pm form"),
        $q->h1("This is a basic form"),
        $q->start_form( -action => '/cgi-bin/util_ldap_user.pl' ),

            $q->textfield( -name => 'user_id',
                           -value => '[enter username]',
                           -size => 64,
                           -maxlenght => 64
                         ),

            $q->submit(),


        $q->end_form(),
        $q->end_html;

