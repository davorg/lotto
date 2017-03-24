package Lotto;

use strict;
use warnings;
use 5.010;

require Exporter;
our @ISA = qw[Exporter];
our @EXPORT = qw[lotto parse_config parse_args];

our $config;

sub lotto {
  my $type = shift;
  my $lotto = $config->{$type};

  my @nums;
  foreach my $set (@$lotto) {
    my %tries;
    while (keys %tries < $set->{count}) {
      $tries{(int rand $set->{limit}) + 1}++;
    }
    push @nums, [ sort { $a <=> $b} keys %tries ];
  }

  return @nums;
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

sub parse_args {
  parse_config() unless keys %$config;
  my ($type, $count) = qw[lotto 1];
  my @errs;

  if (@_ == 2) {
    ($type, $count) = (shift, shift);
    ($type, $count) = ($count, $type) if $count =~ /\D/;
    if ($count =~ /\D/) {
      push @errs, "$count doesn't look like a positive integer";
    }
    if (! exists $config->{$type}) {
      push @errs, qq["$type" is not a recognised type of lottery];
    }
  }

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

  if (@_ || @errs) {
    push @errs, 'Usage: lotto [' .
      join('|', keys %$config) .
      "] [count]\n";
    die join "\n", @errs;
  }

  return ($type, $count);
}

1;

__DATA__
euro:5x50:2x11
lotto:6x59
thunder:5x39:1x14
