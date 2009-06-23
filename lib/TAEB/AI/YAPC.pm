package TAEB::AI::YAPC;
use TAEB::OO;
extends 'TAEB::AI';

sub next_action {
    my $self = shift;
    $self->currently('searching');
    return TAEB::Action::Search->new(iterations => 1);
}

__PACKAGE__->meta->make_immutable;

1;
