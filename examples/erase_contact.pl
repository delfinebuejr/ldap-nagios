#!/usr/bin/perl

use strict;
use warnings;

use lib '../lib/';

use Data::Dumper;
use NagiosConfigObjects;

my $file = '/home/svn_nagios_config/nagios/etc/objects/contacts.cfg';
my $filter = 'contact';
my $target = 'delfin ebue';


my $obj = NagiosConfigObjects->new({
                                    file => $file,
                                    filter => $filter
                                  });

# print Dumper($obj);

$obj->erase_object($target);
