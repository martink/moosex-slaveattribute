#!perl

use Test::More tests => 3;

BEGIN {
    use_ok( 'MooseX::SlaveAttribute' );
    use_ok( 'MooseX::SlaveAttribute::Accessor' );
    use_ok( 'Moose::Meta::Attribute::Custom::Trait::Slave' );
}

diag( "Testing MooseX::SlaveAttribute $MooseX::SlaveAttribute::VERSION, Perl $], $^X" );
