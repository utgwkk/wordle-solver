package Wordle::Questioner::Interactive;
use strict;
use warnings;
use v5.30;
use parent qw(Wordle::Questioner);
use Carp qw(croak);

sub new {
    my ($class) = @_;

    my $self = $class->SUPER::new;
    $self->{last_result} = [];

    bless $self, $class;
}

sub generate_answer {
    # noop
}

sub set_answer {
    # noop
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

    $self->{last_result} = [ @ret ];
    return @ret;
}

sub is_answer {
    my ($self) = @_;

    return scalar(grep { $_ eq 'HIT' } $self->{last_result}->@*) == 5;
}

1;
