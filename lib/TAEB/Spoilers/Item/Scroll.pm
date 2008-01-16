#!/usr/bin/env perl
package TAEB::Spoilers::Item::Scroll;
use MooseX::Singleton;
extends 'TAEB::Spoilers::Item';

has list => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $scrolls = {
            'scroll of mail' => {
                cost       => 0,
                marker     => 2,
                appearance => 'stamped',
            },
            'scroll of identify' => {
                cost   => 20,
                marker => 14,
            },
            'scroll of light' => {
                cost   => 50,
                marker => 8,
            },
            'scroll of blank paper' => {
                cost       => 60,
                marker     => 0,
                appearance => 'unlabeled',
            },
            'scroll of enchant weapon' => {
                cost   => 60,
                marker => 16,
            },
            'scroll of enchant armor' => {
                cost   => 80,
                marker => 16,
            },
            'scroll of remove curse' => {
                cost   => 80,
                marker => 16,
            },
            'scroll of confuse monster' => {
                cost   => 100,
                marker => 12,
            },
            'scroll of destroy armor' => {
                cost   => 100,
                marker => 10,
            },
            'scroll of fire' => {
                cost   => 100,
                marker => 8,
            },
            'scroll of food detection' => {
                cost   => 100,
                marker => 8,
            },
            'scroll of gold detection' => {
                cost   => 100,
                marker => 8,
            },
            'scroll of magic mapping' => {
                cost   => 100,
                marker => 8,
            },
            'scroll of scare monster' => {
                cost   => 100,
                marker => 20,
            },
            'scroll of teleportation' => {
                cost   => 100,
                marker => 20,
            },
            'scroll of amnesia' => {
                cost   => 200,
                marker => 8,
            },
            'scroll of create monster' => {
                cost   => 200,
                marker => 10,
            },
            'scroll of earth' => {
                cost   => 200,
                marker => 8,
            },
            'scroll of taming' => {
                cost   => 200,
                marker => 20,
            },
            'scroll of charging' => {
                cost   => 300,
                marker => 16,
            },
            'scroll of genocide' => {
                cost   => 300,
                marker => 30,
            },
            'scroll of punishment' => {
                cost   => 300,
                marker => 10,
            },
            'scroll of stinking cloud' => {
                cost   => 300,
                marker => 20,
            },
        };

        # tag each scroll with its name and weight
        while (my ($name, $stats) = each %$scrolls) {
            $stats->{name}   = $name;
            $stats->{weight} = 5;
            $stats->{plural} = $name =~ s/scroll/scrolls/;
        }

        return $scrolls;
    },
);

has randomized_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        [map { "scroll labeled $_" } ('ZELGO MER', 'JUYED AWK YACC', 'NR 9',
                                      'XIXAXA XOXAXA XUXAXA', 'PRATYAVAYAH',
                                      'DAIYEN FOOELS', 'LEP GEX VEN ZEA',
                                      'PRIRUTSENIE', 'ELBIB YLOH', 'TEMOV',
                                      'VERR YED HORRE', 'VENZAR BORGAVVE',
                                      'THARR', 'YUM YUM', 'KERNOD WEL',
                                      'ELAM EBOW', 'DUAM XNAHT', 'KIRJE',
                                      'ANDOVA BEGARIN', 'VE FORBRYDERNE',
                                      'HACKEM MUCHE', 'VELOX NEB', 'READ ME',
                                      'FOOBIE BLETCH', 'GARVEN DEH')];
    }
);

has constant_appearances => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { ['stamped scroll', 'unlabeled scroll'] },
);

sub scroll {
    my $self = shift;
    my $item = shift;

    $item = $item->identity if ref($item);
    return $self->list->{$item};
}

1;

