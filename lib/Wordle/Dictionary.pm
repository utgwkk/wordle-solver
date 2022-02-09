package Wordle::Dictionary;
use strict;
use warnings;
use List::Util qw(uniq);

use constant ALL_WORDS => do {
    open my $fh, '<', '/usr/share/dict/words';
    my @words = grep { /^[a-z]{5}$/ } <$fh>;
    chomp @words;
    [ uniq @words ];
};

1;
