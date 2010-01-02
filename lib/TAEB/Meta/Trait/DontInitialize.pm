package TAEB::Meta::Trait::DontInitialize;
use Moose::Role;
Moose::Util::meta_attribute_alias('TAEB::DontInitialize');

no Moose::Role;

1;
