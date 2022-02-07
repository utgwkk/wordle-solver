use strict;
use warnings;
use v5.30;

use Carp qw(croak);

use Wordle::Dictionary;

sub is_answer {
    my (@result) = @_;
    return scalar(grep { $_ eq 'HIT' } @result) == 5;
}

my @all_words = Wordle::Dictionary::ALL_WORDS->@*;

# server: choose words
my $answer = $all_words[int rand @all_words];

sub handle_input {
    my ($input) = @_;
    croak 'input length must be 5' unless length $input == 5;

    my @result = ();

    for my $idx (0..4) {
        my $input_ch = substr $input, $idx, 1;
        my $answer_ch = substr $answer, $idx, 1;

        if ($input_ch eq $answer_ch) {
            push @result, 'HIT';
        } elsif ($answer =~ /$input_ch/x) {
            push @result, 'BLOW';
        } else {
            push @result, 'NONE';
        }
    }

    return @result;
}

sub choose_input_by_chars {
    my ($chars, $candidate_words, $used_words) = @_;

    my $predicate = build_predicate($chars, $used_words);
    my @words = grep { $predicate->($_) } @$candidate_words;

    die 'no candidate words' unless @words;

    return $words[int rand @words];
}

sub choose_input {
    my ($try_num, $candidate_words, $chars, $used_words) = @_;

    if ($try_num == 0) {
        return 'arise';
    } elsif ($try_num == 1) {
        return 'cough';
    } else {
        return choose_input_by_chars($chars, $candidate_words, $used_words);
    }
}

sub build_predicate {
    my ($chars, $used_words) = @_;

    my @none_chars = grep { $chars->{$_} == -2 } sort keys %$chars;
    my @blow_chars = grep { $chars->{$_} == -1 } sort keys %$chars;
    my $hit_word_re = do {
        my $re_str = '';
        my %idx_to_ch = map { $chars->{$_} => $_ } grep { $chars->{$_} >= 0 } sort keys %$chars;
        for my $idx (0..4) {
            if (exists $idx_to_ch{$idx}) {
                $re_str .= $idx_to_ch{$idx};
            } else {
                $re_str .= '.';
            }
        }
        $re_str;
    };

    return sub {
        my ($word) = @_;

        return 0 if exists $used_words->{$word};
        return 0 unless $word =~ /$hit_word_re/x;

        return 0 if @none_chars && $word =~ /[@none_chars]/x;

        for my $ch (@blow_chars) {
            return 0 unless $word =~ /$ch/x
        }

        return 1;
    }
}


my $try_num = 0;
# -3: UNUSED
# -2: NONE
# -1: BLOW
# 0, 1, 2, 3, 4: HIT with index
my %chars = map { $_ => -3 } ('a'..'z');
my @candidate_words = @all_words;
my %used_words = ();

while (1) {
    my $input = choose_input($try_num, \@candidate_words, \%chars, \%used_words);
    $used_words{$input} = 1;
    my @result = handle_input($input);
    say "$input => " . join ", ", @result;
    if (is_answer(@result)) {
        last;
    }

    for my $idx (0..4) {
        my $input_ch = substr $input, $idx, 1;
        if ($result[$idx] eq 'HIT') {
            $chars{$input_ch} = $idx;
        } elsif ($result[$idx] eq 'BLOW') {
            $chars{$input_ch} = -1;
        } elsif ($result[$idx] eq 'NONE') {
            $chars{$input_ch} = -2;
        }
    }

    @candidate_words = do {
        my $pred = build_predicate(\%chars, \%used_words);
        grep { $pred->($_) } @candidate_words;
    };

    $try_num++;
}
