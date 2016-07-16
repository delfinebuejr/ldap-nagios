#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';

use NagiosConfigObjects;

use Test::More tests => 2;

my $file = '/var/www/cgi-bin/contacts.cfg';
my $filter = 'contacts';

use_ok('NagiosConfigObjects');

ok(NagiosConfigObjects->new({
                             file => $file,
                             filter => $filter
                            }));
