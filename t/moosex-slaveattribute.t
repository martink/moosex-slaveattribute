use strict;
use warnings;
use lib 't/lib', 'lib';

use Test::Warn;
use Test::More tests => 11;

use_ok( 'MooseX::SlaveAttribute' );

{
    warning_is { require Line }
       'Attribute border_color has a default and a Slave trait at the same time. Using default.',
       'A warning is thrown for attribute that have both a Slave trait and a default value';

    my $l = Line->new;

    is $l->line_color,      'red',      q{Slaves w/o default take master's value};
    is $l->stroke_color,    'red',      q{Slaves of slaves return correct value};
    is $l->border_color,    'mauve',    q{Slaves with a default value do not follow master};
    
    $l->color( 'indigo' );
    is $l->line_color,      'indigo',   q{Slaves follow master's value if it changes};
    is $l->stroke_color,    'indigo',   q{Slaves of slaves follow master as well};

    $l->line_color( 'ecru' );
    is $l->line_color,      'ecru',     q{Slaves take on their own value when they are set};
    is $l->stroke_color,    'ecru',     q{Slaves of slaves now follow their 'slave-master'};

    $l->color( 'burgundy' );
    is $l->line_color,      'ecru',     q{Slaves stop following master when they are set};
}

{
    require Bar;

    my $b = Bar->new;

    is $b->background_color, 'red',     q{Slave attributes follow masters in super class};
}

