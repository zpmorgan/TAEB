package TAEB::Action::Role::Monster;
use Moose::Role;

requires 'victim_tile';

sub monster {
    my $self = shift;
    $self->victim_tile && $self->victim_tile->monster;
}

sub has_monster {
    my $self = shift;
    $self->victim_tile && $self->victim_tile->has_monster;
}

no Moose::Role;

1;

