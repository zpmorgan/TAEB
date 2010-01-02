package TAEB::World;
use strict;
use warnings;
use TAEB::Meta::Overload;

use Module::Pluggable (
    require     => 1,
    sub_name    => 'load_nhi_classes',
    search_path => ['NetHack::Item'],
    except      => qr/Meta|Role/,
);

use Module::Pluggable (
    require     => 1,
    sub_name    => 'load_world_classes',
    search_path => ['TAEB::World'],
);

sub _find_item_role {
    my $item_class = shift;
    (my $role = $item_class) =~ s/^NetHack/TAEB::Role/;
    while (1) {
        if ($role eq 'TAEB::Role') {
            TAEB->log->moose("Couldn't find a role to apply to $item_class",
                             level => 'error');
            return;
        }
        if (eval { local $SIG{__DIE__}; Class::MOP::load_class($role) }) {
            return $role;
        }
        $role =~ s/::[^:]*$//;
    }
}

for my $class (__PACKAGE__->load_nhi_classes) {
    next if $class =~ /Spoiler/;
    taebify($class);
}

sub taebify {
    my $class = shift;

    (my $taeb_class = $class) =~ s/^NetHack::Item/TAEB::World::Item/;
    Moose::Meta::Class->create(
        $taeb_class,
        superclasses => [$class],
        roles        => [_find_item_role($class)],
    );

    # add overloading to taeb_class
    my $failed = not eval <<OVERLOAD; ## no critic (ProhibitStringyEval)
        package $taeb_class;
        use overload \%TAEB::Meta::Overload::default;
        1;
OVERLOAD
    die $@ if $failed;
}

__PACKAGE__->load_world_classes;

1;

