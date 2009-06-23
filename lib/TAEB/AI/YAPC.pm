package TAEB::AI::YAPC;
use TAEB::OO;
extends 'TAEB::AI';

sub next_action {
    my $self = shift;
    my $path;
    my @enemies;
    TAEB->each_adjacent(sub {
        my ($tile, $direction) = @_;
        push @enemies, $direction if $tile->has_enemy;
    });
    if (@enemies) {
        $self->currently('attacking');
        return TAEB::Action::Melee->new(direction => $enemies[0]);
    }
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
