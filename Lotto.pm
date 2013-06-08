package Lotto;

use strict;
use warnings;
use 5.010;

require Exporter;
our @ISA = qw[Exporter];
our @EXPORT = qw[lotto parse_config parse_args];

sub lotto {
  my $lotto = shift;

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
  my $config;

  while (<DATA>) {
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

sub parse_args {
  my $config = shift;
  my ($type, $count) = qw[lotto 1];
  my @errs;

  if (@_ == 2) {
    $type = shift;
    if (! exists $config->{$type}) {
      push @errs, qq["$type" is not a recognised type of lottery];
    }
  }

  if (@_ == 1) {
    $count = shift;
    if ($count !~ /^\d+$/) {
      push @errs, qq["$count" doesn't look like a positive integer];
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
lotto:6x49
thunder:5x39:1x14
