#!/usr/bin/env perl
package TAEB::Action::Read;
use TAEB::OO;
extends 'TAEB::Action';
with 'TAEB::Action::Role::Item';
use List::MoreUtils 'any';

use constant command => "r";

has '+item' => (
    isa      => 'TAEB::Type::Item',
    required => 1,
);

sub respond_read_what { shift->item->slot }

sub post_responses {
    my $self = shift;
    my $item = $self->item;

    if ($item->class eq 'scroll') {
        TAEB->inventory->decrease_quantity($item->slot)
    }

    $self->check_discoveries;
    $self->check_inventory;
}

sub msg_learned_spell {
    my $self = shift;
    my $name = shift;

    $self->item->identify_as("spellbook of $name");
}

sub can_read {
    my $self = shift;
    my $item = shift;

    return 0 unless $item->class eq 'scroll' or $item->class eq 'spellbook';
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

