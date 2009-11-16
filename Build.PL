use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Text::MicroTemplate::File::BindVars',
    license             => 'perl',
    dist_author         => q{Taro Sako <roteshund+cpan@gmail.com>},
    dist_version_from   => 'lib/Text/MicroTemplate/File/BindVars.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Text-MicroTemplate-File-BindVars-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
