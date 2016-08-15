#!/usr/bin/perl

use strict;
use warnings;

use lib '../lib/';

use Data::Dumper;
use NagiosConfigObjects;


my $file = '/tmp/nnit-dfie/contacts.cfg';
my $filter = 'contact';
#my $filter = 'contactgroup';

my $obj = NagiosConfigObjects->new({
                                    file => $file,
                                    filter => $filter
                                  });

# print Dumper($obj);

my $test = $obj->get_allobjects;    # this returns a collection of configobject.pm objects
                                    # use configobject.pm methods to access data for each object content

#print Dumper($test);


foreach my $item (@{$test}) {  # iterate each HASH_ref

    my $attr = 'contact_name';
    my $value = $item->get_data($attr);
    
    print "$value \n";
}


