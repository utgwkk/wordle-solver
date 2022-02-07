package Wordle::Questioner;
use strict;
use warnings;

use Carp qw(croak);

use Wordle::Dictionary;

sub new {
    my ($class) = @_;

    bless +{}, $class;
}

sub answer {
    shift->{answer};
}

sub generate_answer {
    my ($self) = @_;

    my @all_words = Wordle::Dictionary::ALL_WORDS->@*;
    $self->{answer} = $all_words[int rand @all_words];
}

sub handle_input {
    my ($self, $input) = @_;
    croak 'input length must be 5' unless length $input == 5;

    my @result = ();

    for my $idx (0..4) {
        my $input_ch = substr $input, $idx, 1;
        my $answer_ch = substr $self->answer, $idx, 1;

        if ($input_ch eq $answer_ch) {
            push @result, 'HIT';
        } elsif ($self->answer =~ /$input_ch/x) {
            push @result, 'BLOW';
        } else {
            push @result, 'NONE';
        }
    }

    return @result;
}

1;
