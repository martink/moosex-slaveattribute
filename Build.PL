use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MooseX::SlaveAttribute',
    license             => 'perl',
    dist_author         => 'Martin Kamerbeek <mhg@cpan.org>',
    dist_version_from   => 'lib/MooseX/SlaveAttribute.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'MooseX-SlaveAttribute-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
