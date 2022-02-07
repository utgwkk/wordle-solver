package Wordle::Dictionary;
use strict;
use warnings;

use constant ALL_WORDS => do {
    open my $fh, '<', '/usr/share/dict/words';
    my @words = grep { /^[a-z]{5}$/ } <$fh>;
    chomp @words;
    [ @words ];
};

1;
