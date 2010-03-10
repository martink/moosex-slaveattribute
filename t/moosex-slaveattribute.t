
use Test::Warn;
use Test::More tests => 9;

use_ok( 'MooseX::SlaveAttribute' );

{
    package Line;
    use Moose;

    has color => (
        is      => 'rw',
        default => 'red',
    );
    has line_color => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'color',
    );
    has stroke_color => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'line_color',
    );
    has border_color => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'color',
        default => 'mauve',
    );
}

{
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

