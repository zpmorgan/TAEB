package TAEB::Action::Travel;
use TAEB::OO;
extends 'TAEB::Action';

has target_tile => (
    is       => 'ro',
    isa      => 'TAEB::World::Tile',
    provided => 1,
    required => 1,
);

sub command {
    my $self = shift;
    return "_";
}

sub location_controlled_tele {
    my $self = shift;
    my $target = $self->target_tile;
    return $target if $target->is_walkable && !$target->has_monster;
    my @adjacent = $target->grep_adjacent(sub {
        my $t = shift;
        return $t->is_walkable && !$t->has_monster;
    });
    return unless @adjacent;
    return $adjacent[0];
}

sub location_travel {
    my $self = shift;
    return $self->target_tile;
}

sub done {
    my $self = shift;
    # NetHack doesn't show or tell us what's on the floor when we
    # travel. So we have to check manually.
    TAEB->send_message('check', 'floor');
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

