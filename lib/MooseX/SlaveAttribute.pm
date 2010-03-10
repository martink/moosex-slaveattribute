package MooseX::SlaveAttribute;

use warnings;
use strict;

#--------------------------------------------------------
package MooseX::SlaveAttribute;
use Moose::Role;
use Carp;

has master => (
    is          => 'rw',
    predicate   => 'has_master_attr',
);

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

=cut

our $VERSION = '0.1';

=head1 SYNOPSIS


Perhaps a little code snippet.

    use MooseX::SlaveAttribute;

    my $foo = MooseX::SlaveAttribute->new();
    ...

=head1 AUTHOR

Martin Kamerbeek, C<< <mhg at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-slaveattribute at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-SlaveAttribute>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

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


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Martin Kamerbeek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

