use strict;
use warnings;
use v5.30;

use Carp qw(croak);

use Wordle::Questioner;
use Wordle::Solver;

my $questioner = Wordle::Questioner->new;
$questioner->generate_answer;

my $solver = Wordle::Solver->new;

while (1) {
    my $input = $solver->choose_input;
    $solver->mark_word_as_used($input);

    my @result = $questioner->handle_input($input);
    say "$input => " . join ", ", @result;
    if ($questioner->is_answer($input)) {
        last;
    }

    $solver->mark_result($input, @result);
    $solver->filter_candidate_words;
    $solver->increment_try_num;
}
