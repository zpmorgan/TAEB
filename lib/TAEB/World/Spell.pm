package TAEB::World::Spell;
use TAEB::OO;
use TAEB::Util qw/max min/;

use overload %TAEB::Meta::Overload::default;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has learned_at => (
    is       => 'rw',
    isa      => 'Int',
    default  => sub { TAEB->turn },
);

has fail => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has slot => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has spoiler => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my $self = shift;
        NetHack::Item::Spoiler->spoiler_for("spellbook of " . $self->name);
    },
);

for my $attribute (qw/level read marker role emergency/) {
    __PACKAGE__->meta->add_method($attribute => sub {
        my $self = shift;
        $self->spoiler->{$attribute};
    });
}

sub castable {
    my $self = shift;

    return 0 if $self->forgotten;
    return 0 if $self->power > TAEB->power;

    # "You are too hungry to cast!" (detect food is exempted by NH itself)
    return 0 if TAEB->nutrition <= 10 && $self->name ne 'detect food';

    return 1;
}

sub failure_rate {
    my $self = shift;
    my %penalties = (
        Arc => {
            base => 5,  emergency =>  0, shield => 2, suit => 10, stat => 'int'
        },
        Bar => {
            base => 14, emergency =>  0, shield => 0, suit => 8,  stat => 'int'
        },
        Cav => {
            base => 12, emergency =>  0, shield => 1, suit => 8,  stat => 'int'
        },
        Hea => {
            base => 3,  emergency => -3, shield => 2, suit => 10, stat => 'wis'
        },
        Kni => {
            base => 8,  emergency => -2, shield => 0, suit => 9,  stat => 'wis'
        },
        Mon => {
            base => 8,  emergency => -2, shield => 2, suit => 20, stat => 'wis'
        },
        Pri => {
            base => 3,  emergency => -3, shield => 2, suit => 10, stat => 'wis'
        },
        Ran => {
            base => 9,  emergency =>  2, shield => 1, suit => 10, stat => 'int'
        },
        Rog => {
            base => 8,  emergency =>  0, shield => 1, suit => 9,  stat => 'int'
        },
        Sam => {
            base => 10, emergency =>  0, shield => 0, suit => 8,  stat => 'int'
        },
        Tou => {
            base => 5,  emergency =>  1, shield => 2, suit => 10, stat => 'int'
        },
        Val => {
            base => 10, emergency => -2, shield => 0, suit => 9,  stat => 'wis'
        },
        Wiz => {
            base => 1,  emergency =>  0, shield => 3, suit => 10, stat => 'int'
        },
    );

    # start with base penalty
    my $penalty = $penalties{TAEB->role}->{base};

    # Inventory penalty calculation
    # first the shield!
    $penalty += $penalties{TAEB->role}->{shield}
             if defined TAEB->equipment->shield;
    # body armor, complicated with the robe
    if (defined TAEB->equipment->bodyarmor) {
        my $suit_penalty = 0;
        $suit_penalty = $penalties{TAEB->role}->{suit}
                      if TAEB->equipment->bodyarmor->is_metallic;
        # if wearing a robe, either halve the suit penalty or negate completely 
        if (defined TAEB->equipment->cloak
           && TAEB->equipment->cloak->name eq 'robe') {
            if ($suit_penalty > 0) {
                $suit_penalty = int($suit_penalty / 2);
            }
            else {
                $suit_penalty = -($penalties{TAEB->role}->{suit});
            }
        }
        $penalty += $suit_penalty;
    }
    # metallic helmet, except if HoB
    $penalty += 4 if defined TAEB->equipment->helmet
                  && TAEB->equipment->helmet->is_metallic
                  && TAEB->equipment->helmet->name ne 'helm of brilliance';
    # metallic gloves
    $penalty += 6 if defined TAEB->equipment->gloves
                  && TAEB->equipment->gloves->is_metallic;
    # metallic boots
    $penalty += 2 if defined TAEB->equipment->boots
                  && TAEB->equipment->boots->is_metallic;

    $penalty += $penalties{TAEB->role}->{emergency} if $self->emergency;
    $penalty -= 4 if $self->role eq TAEB->role;

    my $chance;
    my $SKILL = 0; # XXX: this needs to reference skill levels
    my $basechance = int(TAEB->($penalties{TAEB->role}->{stat}) * 11 / 2);
    my $diff = (($self->level - 1) * 4 - ($SKILL * 6 + int(TAEB->xl / 3) + 1));
    if ($diff > 0) {
        $chance = $basechance - int(sqrt(900 * $diff + 2000));
    }
    else {
        my $learning = int(((-15) * $diff) / $SKILL);
        $chance = $basechance + min($learning, 20);
    }

    $chance = max(min($chance, 120), 0);

    # shield and special spell

    $chance = int($chance * (20 - $penalty) / 15) - $penalty;
    $chance = max(min($chance, 100), 0);

    return $chance;
}

sub forgotten {
    my $self = shift;
    return TAEB->turn > $self->learned_at + 20_000;
}

sub debug_line {
    my $self = shift;

    return sprintf '%s - %s (%d]',
           $self->slot,
           $self->name,
           $self->learned_at;
}

sub power { 5 * shift->level }

__PACKAGE__->meta->make_immutable;

1;

__END__

=head2 castable

Can this spell be cast this turn? This does not only take into account spell
age, but also whether you're confused, have enough power, etc.

=cut

