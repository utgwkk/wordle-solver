package Wordle::Solver;
use strict;
use warnings;

use Wordle::Dictionary;

sub new {
    my ($class) = @_;

    bless +{
        try_num => 0,
        candidate_words => [ Wordle::Dictionary::ALL_WORDS->@* ],
        # -3: UNUSED
        # -2: NONE
        # -1: BLOW
        # 0, 1, 2, 3, 4: HIT with index
        chars => { map { $_ => -3 } 'a'..'z' },
        used_words => +{},
    }, $class;
}

sub choose_input {
    my ($self) = @_;

    if ($self->{try_num} == 0) {
        return 'arise';
    } elsif ($self->{try_num} == 1) {
        return 'cough';
    } else {
        return $self->_choose_input_by_chars;
    }
}

sub _choose_input_by_chars {
    my ($self) = @_;

    my $predicate = $self->_build_predicate;
    my @words = grep { $predicate->($_) } $self->{candidate_words}->@*;

    die 'no candidate words' unless @words;

    return $words[int rand @words];

}

sub _build_predicate {
    my ($self) = @_;

    my @none_chars = grep { $self->{chars}->{$_} == -2 } sort keys $self->{chars}->%*;
    my @blow_chars = grep { $self->{chars}->{$_} == -1 } sort keys $self->{chars}->%*;
    my $hit_word_re = do {
        my $re_str = '';
        my %idx_to_ch = map { $self->{chars}->{$_} => $_ } grep { $self->{chars}->{$_} >= 0 } sort keys $self->{chars}->%*;
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

        return 0 if exists $self->{used_words}->{$word};
        return 0 unless $word =~ /$hit_word_re/x;

        return 0 if @none_chars && $word =~ /[@none_chars]/x;

        for my $ch (@blow_chars) {
            return 0 unless $word =~ /$ch/x
        }

        return 1;
    };
}

sub mark_word_as_used {
    my ($self, $word) = @_;

    $self->{used_words}->{$word} = 1;
}

sub filter_candidate_words {
    my ($self) = @_;

    $self->{candidate_words} = do {
        my $pred = $self->_build_predicate;
        [ grep { $pred->($_) } $self->{candidate_words}->@* ];
    };
}

sub mark_result {
    my ($self, $input, @result) = @_;

    for my $idx (0..4) {
        my $input_ch = substr $input, $idx, 1;
        if ($result[$idx] eq 'HIT') {
            $self->{chars}->{$input_ch} = $idx;
        } elsif ($result[$idx] eq 'BLOW') {
            $self->{chars}->{$input_ch} = -1;
        } elsif ($result[$idx] eq 'NONE') {
            $self->{chars}->{$input_ch} = -2;
        }
    }
}

sub increment_try_num {
    my ($self) = @_;

    $self->{try_num}++;
}

1;