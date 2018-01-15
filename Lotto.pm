package Lotto;

use strict;
use warnings;
use 5.010;

our $config;

sub play {
  my $self = shift;

  my $lotto = $config->{$self->{type}};

  my @results;

  for (1 .. $self->{count}) {
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

  return @results;
}

sub parse_config {
  while (<DATA>) {
    chomp;
    my @conf = split /:/;
    my $key = shift @conf;
    foreach my $def (@conf) {
      my ($count, $limit) = split /x/, $def;
      push @{$config->{$key}}, { limit => $limit, count => $count };
    }
  }
}

sub new {
  my $class = shift;

  parse_config() unless keys %$config;

  my ($type, $count) = qw[lotto 1];
  my @errs;

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

  if (@_ == 2) {
    ($count, $type)   = (undef, undef);
    my ($first, $second) = (shift, shift);
    for ($first, $second) {
      if (/^\d+$/) {
        $count = $_;
      }
      if (exists $config->{$_}) {
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

  if (@_ || @errs) {
    push @errs, 'Usage: lotto [' .
      join('|', keys %$config) .
      "] [count]\n";
    die join "\n", @errs;
  }

  return bless {
    type => $type,
    count => $count,
  }, $class;
}

1;

__DATA__
euro:5x50:2x11
lotto:6x59
thunder:5x39:1x14
