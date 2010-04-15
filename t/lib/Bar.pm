package Bar;

use strict;
use warnings;

use Moose;

extends 'Line';

has background_color => (
    is      => 'rw',
    traits  => [ 'Slave' ],
    master  => 'color',
);

1;

