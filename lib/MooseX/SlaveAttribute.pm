package MooseX::SlaveAttribute;

use warnings;
use strict;

our $VERSION = '0.1';

#--------------------------------------------------------
package MooseX::SlaveAttribute;
use Moose::Role;
use Carp;

has master => (
    is          => 'rw',
    predicate   => 'has_master_attr',
);

# Warn that slave traits and default values don't mix.
before install_accessors => sub {
    my $self = shift;
    
    if ( $self->has_default ) {
        carp sprintf 'Attribute %s has a default and a Slave trait at the same time. Using default.', $self->name;
    }
};

around accessor_metaclass => sub {
    my ($orig, $self, @rest) = @_;

    return Moose::Meta::Class->create_anon_class(
        superclasses => [ $self->$orig(@_) ],
        roles => [ 'MooseX::SlaveAttribute::Accessor' ],
        cache => 1
    )->name;
};

#--------------------------------------------------------
package MooseX::SlaveAttribute::Accessor;
use Moose::Role;

around _inline_get => sub {
    my ($orig, $self, $instance, $value) = @_;

    my $master  = $self->associated_attribute->master;
    my $name    = $self->associated_attribute->name;

    my $code    = sprintf(
          qq| ( '$master' && !%s->meta->get_attribute('$name')->has_value( %s ) )               |
        . qq|     ? %s->meta->find_attribute_by_name('$master')->get_read_method_ref->( %s )    |
        . qq|     : %s                                                                          |
        . qq|     ;                                                                             |,
        $instance, $instance,
        $instance, $instance,
        $self->$orig($instance, $value),
    );

    return $code;
};

#--------------------------------------------------------
package Moose::Meta::Attribute::Custom::Trait::Slave;

sub register_implementation {'MooseX::SlaveAttribute'};


=head1 NAME

MooseX::SlaveAttribute - Let your attributes default to the value of a master attribute.

=head1 VERSION

Version 0.1

=head1 SYNOPSIS

    {
        package Foo;
        use Moose;
        use MooseX::SlaveAttribute;

        has color           => ( is => 'rw', default => 'red' );
        has line_color      => ( is => 'rw', traits => ['Slave'], master => 'color' );
        has stroke_color    => ( is => 'rw', traits => ['Slave'], master => 'line_color' );
    }

    my $f = Foo->new;

    $f->line_color;     # 'red'
    $f->stroke_color;   # 'red'

    $f->color( 'blue' );
    $f->line_color;     # 'blue'
    $f->stroke_color;   # 'blue'

    $f->line_color( 'green' );
    $f->line_color      # 'green'
    $f->stroke_color    # 'green'

=head1 DESCRIPTION

MooseX::SlaveAttribute allows you to let your attributes default to the values of other attributes. This can be
very handy if you have a lot of attributes that in most cases you want to default to some settable value, while
still being able to give them a custom value if necessary.

If you explicitly assign a value to a slave attribute it will stop following the value of its master.

In order to create a slave attribute give it the 'Slave' trait and pass the name of the master attribute via the
'master' property, like this:

    has foo => (
        is      => 'rw',
        default => 'FOO',
    );

    has bar => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'foo',
    );

Slave attributes can have masters that are are slave attributes themselves, like this:

    has foo => (
        is      => 'rw',
        default => 'FOO',
    );

    has bar => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'foo',
    );

    has baz => (
        is      => 'rw'
        traits  => [ 'Slave' ],
        master  => 'bar',
    );
    

Masters can also be attributes of a super class:

    package Foo;
    use Moose;

    has xyzzy => (
        is      => 'rw',
        default => 'baz',
    }

    package Bar;
    use Moose;
    use MooseX::SlaveAttribute;

    extends 'Foo';

    has zazzy => (
        is      => 'rw',
        traits  => [ 'Slave' ],
        master  => 'xyzzy',
    );

=head1 CAVEATS

Don't give slave attributes a default of their own. If you do, your attribute will not be a slave to its master.
You'll get a warning when you load you class, when you do this, though.

=head1 AUTHOR

Martin Kamerbeek, C<< <mhg at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-slaveattribute at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-SlaveAttribute>. It will help greatly
if you attach a small program that reproduces the bug.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::SlaveAttribute

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-SlaveAttribute>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-SlaveAttribute>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-SlaveAttribute>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-SlaveAttribute/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2010 Martin Kamerbeek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

