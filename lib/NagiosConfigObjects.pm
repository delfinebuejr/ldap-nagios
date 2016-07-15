package NagiosConfigObjects;

## Author: DFIE
## Create Date: 14/07/2016
## Modified Date: 15/07/2016
## create and collect objects defined in a nagios configuration file.
## To Do: Add, Delete, and Modify objects from file

use strict;
use warnings;
use Carp qw(carp croak);
use configobjects;
use Data::Dumper;

sub new {
    my ( $class, $arg_for ) = @_;
    my $self = bless {}, $class;
    $self->_init($arg_for);
    return $self;
}

sub _init {
    my ($self, $arg_for) = @_;
    my $class = $self;
    
    my %hash = %$arg_for;

    my $file = delete $hash{file};
    my $filter = delete $hash{filter};


    unless (defined $file) {croak("no config file was specified!")};
    unless (defined $filter) {croak("filter member cannot be blank!")};
    
    unless (-e $file) {croak("The specified config file does not exist!")};

    if (my $remaining = join ",", keys %hash){
        croak("Unknown keys to $class\::keys: $remaining");
    }

    $self->set_file($file);       # target configuration file
    $self->set_filter($filter);       # comma (,) delimitted string that contains target object type
    $self->_process_file;
}

sub write_object {
    my ( $self , $objdef  ) = @_;

    open(FH, ">>" . $self->{file}) or die $!;

    print FH $objdef;

    close FH;
}

sub erase_object {





}

sub _process_file {

    my ( $self ) = shift;
 
    my $file = $self->get_file;
    my $obj = $self->get_filter;

    open(FH, "<$file") or die $!;

    my @fileobj = <FH>;

    my @nosemicolon = map { (split ";" , $_)[0] } @fileobj;          # remove comments starting with a semicolon

    my @nocomments = map { (split "#" , $_)[0] } @nosemicolon;    # remove comments starting with a hash

    my $filestring = join '_new_' , @nocomments;                                # convert the clean file array to a string

    $self->_create_objects($obj, $filestring,);
    
}

sub _create_objects {

    my ($self, $obj, $filestring) = @_;

    my @allobjects;

    my @x = split "define $obj\{", $filestring;                            # start extracting the target object definition

    my @y = ();

    shift @x;                                                     #dump the first element as it is not an object definition

    foreach my $i (@x) {

        my $nagobj = configobjects->new({
                                        type => $obj,
                                       });

        my @temp = split "}", $i;                                 # complete the extraction of the target object definition

        my $temp1 = $temp[0];                                     # get the data and discard the blank array element $temp[1]

        $temp1 =~ s/_new__new_/_new_/g;                           # cleanup the object definition data

        my @definedobj = split '_new_' , $temp1;

        pop @definedobj;                                          # remove the empty first element
        shift @definedobj;                                        # remove the empty last element

        foreach (@definedobj) {

            my @directives = split '_new_', $_;

            foreach my $directive ( @directives ) {

                $directive =~ s/^\s+|\s+$//g;

                my @items = split " ", $directive;
                my $name = $items[0];

                $name =~ s/^\s+|\s+$//g;
                shift @items;

                my $value = join ' ', @items;


                $value =~ s/^\s+|\s+$//g;

                $nagobj->set_data($name, $value);

           }
        }
           push @allobjects, $nagobj;
    }

    $self->set_count(scalar @allobjects);
    $self->_set_allobjects(@allobjects)
    
}

sub get_file {
    my $self = shift;
    return $self->{file};
}

sub get_filter {
    my $self = shift;
    return $self->{filter};
}

sub _set_allobjects {
    my ($self, @data) = @_;
    $self->{allobjects} = \@data;
}

sub set_file {
    my ( $self, $file ) = @_;
    $self->{file} = $file;
}

sub set_count {
    my ($self, $count) = @_;
    $self->{count} = $count
}

sub set_filter {
    my ( $self, $filter ) = @_;
    $self->{filter} = $filter;
}

sub get_count {
    my $self = shift;
    return $self->{count};
}

sub get_allobjects {
    my ($self) = shift;
    return $self->{allobjects};
}

1;
