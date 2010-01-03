package TAEB::OO;
use Moose ();
use MooseX::ClassAttribute ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use namespace::autoclean ();

use TAEB::Meta::Trait::Persistent;
use TAEB::Meta::Trait::GoodStatus;
use TAEB::Meta::Trait::DontInitialize;
use TAEB::Meta::Types;
use TAEB::Meta::Overload;

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    also      => ['Moose', 'MooseX::ClassAttribute'],
    with_meta => ['extends', 'subscribe'],
    base_class_roles => [
        'TAEB::Role::Initialize',
        'TAEB::Role::Subscription',
        # the memory leak doesn't exist in 5.8, and will (hopefully) be fixed
        # by the 5.10.1 release
        $] == 5.010 ? ('TAEB::Role::WeakenFix') : (),
    ],
);

# make sure using extends doesn't wipe out our base class roles
sub extends {
    my ($meta, @superclasses) = @_;
    Class::MOP::load_class($_) for @superclasses;
    for my $parent (@superclasses) {
        goto \&Moose::extends if $parent->can('does')
                              && $parent->does('TAEB::Role::Initialize');
    }
    # i'm assuming that after apply_base_class_roles, we'll have a single
    # base class...
    my ($superclass_from_metarole) = $meta->superclasses;
    push @_, $superclass_from_metarole;
    goto \&Moose::extends;
}

sub subscribe {
    my $meta = shift;
    my $handler = pop;

    for my $name (@_) {
        my $method_name = "subscription_$name";
        my $super_method = $meta->find_method_by_name($method_name);
        my $method;

        if ($super_method) {
            $method = sub {
                $super_method->execute(@_);
                goto $handler;
            };
        }
        else {
            $method = $handler;
        }

        $meta->add_method($method_name => $method);
    }
}

sub init_meta {
    my ($package, %options) = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class                 => $options{for_class},
        $options{for_class} =~ /^TAEB::Action/ ?
            (attribute_metaclass_roles => ['TAEB::Meta::Trait::Provided'])
          : (),
    );
    goto $init_meta;
}

sub import {
    my $caller = caller;
    namespace::autoclean->import(
        -cleanee => $caller,
    );

    goto $import;
}

sub unimport {
    warn "no TAEB::OO is no longer necessary";
    goto $unimport;
}

1;

