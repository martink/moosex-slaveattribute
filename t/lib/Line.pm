package Line;

use Moose;
use MooseX::SlaveAttribute;

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

1;

