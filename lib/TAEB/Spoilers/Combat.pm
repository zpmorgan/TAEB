package TAEB::Spoilers::Combat;
use strict;
use warnings;
use TAEB::Util 'dice';
use Scalar::Util 'blessed';

# XXX: eventually all of these should be modified to possibly take into account
# the monster we're attacking, so we don't sit around whiffing at a shade and
# doing no damage

sub _barehanded_damage {
    my $self = shift;

    my $role = TAEB->role;
    my ($mindam, $avgdam, $maxdam);
    my $skill_bonus = 0;
    if ($role eq 'Mon' || $role eq 'Sam') {
        ($mindam, $avgdam, $maxdam) = dice 'd4';
        #$skill_bonus = TAEB->skill_level('martial arts');
    }
    else {
        ($mindam, $avgdam, $maxdam) = dice 'd2';
        #$skill_bonus = TAEB->skill_level('bare handed combat');
    }

    $avgdam += TAEB->strength_damage_bonus;
    $avgdam += TAEB->item_damage_bonus;

    $skill_bonus = int($skill_bonus * ($maxdam - 1) / 2);
    $avgdam += $mindam/$maxdam * $skill_bonus;

    return $avgdam;
}

sub _nonweapon_damage {
    my $self = shift;
    my $weapon = shift;

    # XXX: not exactly accurate, but eh
    return 0;
}

# This isn't fully accurate, but it's better than the old approximation;
# speciest weapons are discounted (but brands are full)
# Vorpal and Tsurugi are overestimated
my %artifact_bonus = (
    'Excalibur'                => 5.5,
    'Stormbringer'             => 6,
    'Mjollnir'                 => 12.5,
    'Cleaver'                  => 3.5,
    'Grimtooth'                => 3.5,
    'Sting'                    => 1,
    'Orcrist'                  => 1,
    'Magicbane'                => 5,
    'Frost Brand'              => 'DOUBLE',
    'Fire Brand'               => 'DOUBLE',
    'Dragonbane'               => 1,
    'Demonbane'                => 1,
    'Werebane'                 => 1,
    'Grayswandir'              => 'DOUBLE',
    'Giantslayer'              => 1,
    'Ogresmasher'              => 1,
    'Trollsbane'               => 1,
    'Vorpal Blade'             => 5,
    'Snickersnee'              => 4.5,
    'Sunsword'                 => 1,
    'The Sceptre of Might'     => 'DOUBLE',
    'The Staff of Aesculapius' => 'DOUBLE',
    'The Tsurugi of Muramasa'  => 10,
);

sub _artifact_damage {
    my $self = shift;
    my $weapon = shift;

    # XXX: fix this later
    my $dam = $self->_weapon_damage($weapon);

    if ($artifact_bonus{$weapon->artifact} eq 'DOUBLE') {
        $dam *= 2;
    } else {
        $dam += $artifact_bonus{$weapon->artifact};
    }

    return $dam;
}

sub _weapon_damage {
    my $self = shift;
    my $weapon = shift;

    # arbitrary
    my $avgdam = dice(TAEB->z < 15 ? $weapon->sdam : $weapon->ldam);
    $avgdam += TAEB->strength_damage_bonus;
    $avgdam += TAEB->item_damage_bonus;

    # XXX: need to take into account things like enchantment, etc
    # XXX: important: need to get launcher *melee* damage, not ranged

    return $avgdam;
}

sub damage {
    my $self = shift;
    my $weapon = shift;

    if (!defined $weapon) {
        TAEB->log->spoiler('Tried to get damage statistics from an undef item',
                           level => 'error');
        return 0;
    }

    if (!blessed($weapon) && $weapon eq '-') {
        return $self->_barehanded_damage;
    }

    if ($weapon->type eq 'weapon') {
        if ($weapon->is_artifact) {
            return $self->_artifact_damage($weapon);
        }
        else {
            return $self->_weapon_damage($weapon);
        }
    }
    elsif ($weapon->type eq 'tool' && $weapon->subtype eq 'weapon') {
        return $self->_weapon_damage($weapon);
    }
    else {
        return $self->_nonweapon_damage($weapon);
    }
}

1;

