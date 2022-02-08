package Wordle::Questioner::Interactive;
use strict;
use warnings;
use v5.30;
use parent qw(Wordle::Questioner);
use Carp qw(croak);

sub generate_answer {
    my ($self) = @_;

CHOOSE_ANSWER:
    my $new_answer = <STDIN>;
    chomp $new_answer;

    unless (length $new_answer == 5) {
        warn 'answer must be 5 characters';
        goto CHOOSE_ANSWER;
    }

    $self->set_answer($new_answer);
}

sub handle_input {
    my ($self, $input) = @_;
    croak 'input length must be 5' unless length $input == 5;

    STDERR->say($input);

REPLY:
    my $result = <STDIN>;
    chomp $result;

    unless (length $result == 5) {
        warn 'reply must be 5 characters of h (HIT), b (BLOW), n (NONE)';
        goto REPLY;
    }

    my @ret = ();
    for my $ch ($result =~ /./g) {
        unless ($ch =~ /\A[hbn]\z/) {
            warn 'reply must be 5 characters of h (HIT), b (BLOW), n (NONE)';
            goto REPLY;
        }
        my $res = $ch eq 'h' ? 'HIT' : $ch eq 'b' ? 'BLOW' : 'NONE';
        push @ret, $res;
    }

    return @ret;
}

1;
