#!/usr/bin/env perl
package TAEB::Knowledge::Item;
use Moose;

has appearance => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has type => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has _identities => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    provides  => {
        delete => 'exclude_possibility',
        exists => 'has_possibility',
        keys   => 'possibilities',
    },
);

sub BUILD {
    my $self = shift;

    $self->_identities({ map { $_ => 1 } $self->all_identities });
}

# ignore exclude_possibility if we have one identity left
around exclude_possibility => sub {
    my $orig        = shift;
    my $self        = shift;
    my $possibility = shift;

    my @possibilities = $self->possibilities;
    if (@possibilities == 1) {
        if ($possibilities[0] eq $possibility) {
            TAEB->error("Tried to exclude the last possibility ($possibility) from ");
        }
        return;
    }

    $self->$orig($possibility);
};

# if we narrow it down to one final possibility, exclude it from all others
after exclude_possibility => sub {
    my $self = shift;

    my @possibilities = $self->possibilities;
    my $appearance = $self->appearance;
    my $type = $self->type;

    if (@possibilities == 1) {
        my $identity = shift @possibilities;
        TAEB->debug("($type, $appearance) is a '$identity'. Ruling it out of other appearances.");

        for my $other (values %{ TAEB::Knowledge->appearances->{$type} }) {
            next if $other->appearance eq $appearance;
            $other->rule_out($identity);
        }

        return;
    }

    if (@possibilities == 0) {
        TAEB->error("No possibilities left for ($type, $appearance)!");
    }
};

sub rule_out {
    my $self = shift;
    $self->exclude_possibility($_) for @_;
}

sub rule_out_all_but {
    my $self = shift;
    my %include = map { $_ => 1 } @_;

    for ($self->possibilities) {
        $self->rule_out($_) unless $include{$_};
    }
}

sub identify_as {
    my $self = shift;
    $self->rule_out_all_but(shift);
}

sub is_identified {
    return shift->possibilities == 1;
}

# XXX: price-id code

1;

