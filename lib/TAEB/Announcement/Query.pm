package TAEB::Announcement::Query;
use TAEB::OO;
extends 'TAEB::Announcement';

sub immediate { 1 }

__PACKAGE__->meta->make_immutable;

1;

