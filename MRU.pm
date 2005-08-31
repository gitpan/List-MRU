package List::MRU;

use 5.006;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

# -------------------------------------------------------------------------
# Constructor
sub new
{
  my $class = shift;
  my %arg = @_;
  croak "required argument 'max' missing'" unless defined $arg{max};
  croak "'max' argument not an integer'" unless $arg{max} =~ m/^\d+$/;
  croak "'eq' argument not an subroutine'" 
    if $arg{eq} && ref $arg{eq} ne 'CODE';
  bless {
    max  => $arg{max},
    'eq' => $arg{eq},
    list => [],
  }, $class;
}

# -------------------------------------------------------------------------
# Private methods

sub _truncate
{
  my $self = shift;
  pop @{$self->{list}} while scalar @{$self->{list}} > $self->{max};
}

# -------------------------------------------------------------------------
# Public methods

# Add $item, moving to head of list if already exists
sub add
{
  my $self = shift;
  my $item = shift;
  croak "no item given to add" unless defined $item;
  if ($self->delete($item)) {
    unshift @{$self->{list}}, $item;
  }
  else {
    unshift @{$self->{list}}, $item;
    $self->_truncate;
  }
}

# Delete (first) $item, returning it if found.
sub delete
{
  my $self = shift;
  my $item = shift;
  croak "no item given to delete" unless defined $item;
  my $eq = $self->{eq} || sub { $_[0] eq $_[1] };
  for my $i (0 .. $#{$self->{list}}) {
    if ($eq->($item, $self->{list}->[$i])) {
      return splice @{$self->{list}}, $i, 1;
    }
  }
}

# Accessors
sub list  { wantarray ? @{shift->{list}} : shift->{list} }
sub max   { shift->{max} }
sub count { scalar @{shift->{list}} }

1;

__END__

=head1 NAME

List::MRU - Perl module implementing a simple fixed-size 
MRU-ordered list.

=head1 SYNOPSIS

  use List::MRU;

  # Constructor
  $lm = List::MRU->new(max => 20);
  # Constructor with explicit 'eq' subroutine for obj equality tests
  $lm = List::MRU->new(max => 20, 'eq' => sub {
    $_[0]->stringify eq $_[1]->stringify
  });

  # Add item, moving to head of list if already exists
  $lm->add($item);

  # Iterate in most-recently-added order
  for my $item ($lm->list) {
    print $item;
  }

  # Accessors
  $max = $lm->max;        # max items in list
  $count = $lm->count;    # current items in list


=head1 DESCRIPTION

Perl module implementing a simple fixed-size most-recently-used-
(MRU)-ordered list of values/objects. Well, really it's a most-
recently-added list - items added to the list are just promoted 
to the front of the list if they already exist, otherwise they 
are added there.

Works fine with with non-scalar items, but you will need to
supply an explicit 'eq' subroutine to the constructor to handle
testing for the 'same' object (or alternatively have overloaded
the 'eq' operator for your object).


=head1 SEE ALSO

Tie::Cache::LRU, which was kind of what I wanted, but didn't retain 
ordering.


=head1 AUTHOR

Gavin Carr <gavin@openfusion.com.au>


=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Open Fusion Pty. Ltd.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

