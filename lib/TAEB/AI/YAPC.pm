package TAEB::AI::YAPC;
use TAEB::OO;
extends 'TAEB::AI';

sub next_action {
    my $self = shift;
    my $path;
    $self->currently('exploring');
    $path = TAEB::World::Path->first_match(
        sub { shift->unexplored }
    );
    return $path if $path;
    $self->currently('random walking');
    my $direction = (qw(y u h j k l b n))[int rand 8];
    return TAEB::Action::Move->new(direction => $direction);
}

__PACKAGE__->meta->make_immutable;

1;
