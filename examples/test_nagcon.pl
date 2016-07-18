#!/usr/bin/perl

use strict;
use warnings;

use lib '../lib';

use Data::Dumper;
use NagiosConfigObjects;

my $objcontact = NagiosConfigObjects->new({
                                 file => '/var/www/cgi-bin/contacts.cfg',
                                 filter => 'contact'
                                });


my $objcontactgroup = NagiosConfigObjects->new({
                                 file => '/var/www/cgi-bin/contacts.cfg',
                                 filter => 'contactgroup'
                                });


print Dumper($objcontact->get_allobjects);

print Dumper($objcontactgroup->get_allobjects);
