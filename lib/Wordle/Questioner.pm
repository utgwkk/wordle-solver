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

sub is_answer {
    my ($self, $input) = @_;
    $input eq $self->answer;
}

sub set_answer {
    my ($self, $new_answer) = @_;
    $self->{answer} = $new_answer;
}

sub generate_answer {
    my ($self) = @_;

    my @all_words = Wordle::Dictionary::ALL_WORDS->@*;
    $self->set_answer($all_words[int rand @all_words]);
}

sub handle_input {
    my ($self, $input) = @_;
    croak 'input length must be 5' unless length $input == 5;

    my @result = ();
    my %answer_char_occurences = map { $_ => 0 } $self->answer =~ /./g;
    for my $ch ($self->answer =~ /./g) {
        $answer_char_occurences{$ch}++;
    }

    for my $idx (0..4) {
        my $input_ch = substr $input, $idx, 1;
        my $answer_ch = substr $self->answer, $idx, 1;

        if ($input_ch eq $answer_ch) {
            push @result, 'HIT';
            $answer_char_occurences{$answer_ch}--;
        } elsif ($self->answer =~ /$input_ch/x) {
            if ($answer_char_occurences{$answer_ch} > 0) {
                push @result, 'BLOW';
            } else {
                push @result, 'NONE';
            }
            $answer_char_occurences{$answer_ch}--;
        } else {
            push @result, 'NONE';
        }
    }

    return @result;
}

1;
