#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';

use NagiosConfigObjects;

use Test::More tests => 4;

my $file = '/var/www/cgi-bin/contacts.cfg';
my $filter = 'contacts';

# test 1:
use_ok('NagiosConfigObjects');

# test 2:
ok(NagiosConfigObjects->new({
                             file => $file,
                             filter => $filter
                            }));



my $obj = NagiosConfigObjects->new({
             file => $file,
             filter => $filter
            });


# test 3:
is($obj->get_file, $file, "show target file path");

#test 4:
is($obj->get_filter, $filter, "show filter");


