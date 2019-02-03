package Lotto;

use strict;
use warnings;
use 5.010;

use Moose;
use MooseX::ClassAttribute;

class_has config => (
  isa => 'HashRef',
  is => 'ro',
  lazy_build => 1,
);

sub _build_config {
  my $config;

  while (<Lotto::DATA>) {
    chomp;
    my @conf = split /:/;
    my $key = shift @conf;
    foreach my $def (@conf) {
      my ($count, $limit) = split /x/, $def;
      push @{$config->{$key}}, { limit => $limit, count => $count };
    }
  }

  return $config;
}

has type => (
  isa => 'Str',
  is  => 'ro',
);

has count => (
  isa => 'Int',
  is  => 'ro',
);

sub play {
  my $self = shift;

  my $lotto = $self->config->{$self->type};

  my @results;

  for (1 .. $self->count) {
    my @nums;
    foreach my $set (@$lotto) {
      my %tries;
      while (keys %tries < $set->{count}) {
        $tries{(int rand $set->{limit}) + 1}++;
      }
      push @nums, [ sort { $a <=> $b} keys %tries ];
    }

    push @results, \@nums;
  }


  # TODO: Sort on the correct number of values.
  @results = sort {
    ($a->[0][0] <=> $b->[0][0]) or
    ($a->[0][1] <=> $b->[0][1]) or
    ($a->[0][2] <=> $b->[0][2])
  } @results;

  return @results;
}

around BUILDARGS => sub {
  my $orig  = shift;
  my $class = shift;

  my $config = $class->config;

  # Standard Moose call with hash ref. ->new({ ... })
  # Just pass it on
  if (@_ == 1 and ref $_[0] eq 'HASH') {
    return $class->$orig(@_);
  }

  # Standard Moose call with hash. ->new( ... )
  # Take a ref and pass it on
  if (@_ == 4) {
    return $class->$orig({@_});
  }

  my ($type, $count) = qw[lotto 1];
  my @errs;

  # Single arg will either be a lottery type string or an integer
  if (@_ == 1) {
    if ($_[0] =~ /^\d+$/) {
      $count = shift;
    } elsif (exists $config->{$_[0]}) {
      $type = shift;
    } else {
      push @errs, qq["$_[0]" doesn't look like a positive integer or a ] .
                  qq[type of lottery];
    }
  }

  # Two args should be both a lottery type string and an integer
  if (@_ == 2) {
    ($count, $type)   = (undef, undef);
    my ($first, $second) = (shift, shift);
    for ($first, $second) {
      if (/^\d+$/) {
        $count = $_;
      }
      if ($config->{$_}) {
        $type = $_;
      }
    }
    unless (defined $count) {
      push @errs, "Neither $first nor $second look like a positive integer";
    }
    unless (defined $type) {
      push @errs, "Neither $first nor $second are a recognised type of lottery";
    }
  }

  if (@_ > 2) {
    die "Weird parameters to Lotto constructor: @_\n";
  }

  if (@_ || @errs) {
    push @errs, 'Usage: lotto [' .
      join('|', keys %{$class->config}) .
      "] [count]\n";
    die join "\n", @errs;
  }

  return $class->$orig({
    type => $type,
    count => $count,
  });
};

1;

__DATA__
euro:5x50:2x11
lotto:6x59
thunder:5x39:1x14
