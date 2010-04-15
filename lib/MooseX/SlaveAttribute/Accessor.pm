package MooseX::SlaveAttribute::Accessor;
use strict;
use warnings;

use Moose::Role;

around _inline_get => sub {
    my ($orig, $self, $instance, $value) = @_;

    my $master  = $self->associated_attribute->master;
    my $name    = $self->associated_attribute->name;
    my $code    = sprintf(
          qq| ( '$master' && !%s->meta->find_attribute_by_name('$name')->has_value( %s ) )      |
        . qq|     ? %s->meta->find_attribute_by_name('$master')->get_read_method_ref->( %s )    |
        . qq|     : %s                                                                          |
        . qq|     ;                                                                             |,
        $instance, $instance,
        $instance, $instance,
        $self->$orig($instance, $value),
    );

    return $code;
};

1;

