use strict;
use warnings;
use v5.30;

for my $i (1..10000) {
    my $result = `perl -Ilib solver.pl`;
    if ($? > 0) {
        say -1;
        next;
    }
    say scalar(split /\r?\n/, $result);
}
