package TAEB::Util::Pair;
use TAEB::OO;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has value => (
    is       => 'ro',
    required => 1,
);

use overload (
    fallback => 1,
    q{""} => sub {
        my $self = shift;
        $self->name . ': ' . $self->value
    },
);

__PACKAGE__->meta->make_immutable;
1;
