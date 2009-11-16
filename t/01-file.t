use strict;
use warnings;
use Test::More tests => 19;
use File::Temp qw(tempdir);

use Text::MicroTemplate::File::BindVars;

# simple test
do {
    my $mtb = Text::MicroTemplate::File::BindVars->new( include_path => 't/templates' );
    is $mtb->render_file( 'hello.mt', { name => 'Taro' } )->as_string, "Hello, Taro\n", "bind";
    is $mtb->render_file( 'hello_nobind.mt', 'Taro' )->as_string, "Hello, Taro\n", "no bind";    # no bind
    is $mtb->render_file( 'include.mt', { name => 'Taro' } )->as_string,
      "head\nHello, Taro\n\nfoot\n", "include";
    is $mtb->render_file('package.mt')->as_string, "main\n", "default package";
    is $mtb->render_file('wrapped.mt')->as_string, "abc\nheader\ndef\n\nfooter\nghi\n", 'wrapper';
    is $mtb->render_file('wrapped2.mt')->as_string,
      "abc\nheader\ndef\nheader\nghi\n\nfooter\njkl\n\nfooter\nmno\n", 'wrapper';
    is $mtb->render_file('wrapped_escape.mt')->as_string, "abc\nheader\n<def>\n\nfooter\nghi\n",
      'wrapper';
};

# package name
do {
    my $mtb = Text::MicroTemplate::File::BindVars->new(
        include_path => 't/templates',
        package_name => 'foo',
    );
    is $mtb->render_file( 'hello.mt', { name => 'Taro' } )->as_string, "Hello, Taro\n";
    is $mtb->render_file( 'include.mt', { name => 'Taro' } )->as_string,
      "head\nHello, Taro\n\nfoot\n";
    is $mtb->render_file('package.mt')->as_string, "foo\n", 'package';
};

# cache
do {
    my $dir = tempdir( CLEANUP => 1 );
    my $rewrite = sub {
        open my $fh, '>', "$dir/t.mt"
          or die "cannot open $dir/t.mt:$!";
        print $fh @_;
        close $fh;
    };
    my $mtb = Text::MicroTemplate::File::BindVars->new(
        include_path => $dir,
        use_cache    => 1,
    );
    $rewrite->(1);
    is $mtb->render_file('t.mt')->as_string, '1', 'cache=1 read';
    is $mtb->render_file('t.mt')->as_string, '1', 'cache=1 retry';
    sleep 2;
    $rewrite->(2);
    is $mtb->render_file('t.mt')->as_string, '2', 'cache=1 update';
    is $mtb->render_file('t.mt')->as_string, '2', 'cache=1 update retry';

    # set mode to 2 and remove
    $mtb->use_cache(2);
    unlink "$dir/t.mt"
      or die "failed to remove $dir/t.mt:$!";
    is $mtb->render_file('t.mt')->as_string, '2', 'cache=2 read after cached';
};

# open_layer (default=:utf8)
do {
    use utf8;
    my $mtf = Text::MicroTemplate::File::BindVars->new( include_path => 't/templates', );

    my $output = $mtf->render_file( 'konnitiwa.mt', { target => '他界' } )->as_string;
    is $output, "こんにちは、他界\n", 'utf8 flagged render ok';
    ok utf8::is_utf8($output), 'utf8 flagged output ok';
};

do {
    no utf8;
    my $mtf = Text::MicroTemplate::File::BindVars->new(
        include_path => 't/templates',
        open_layer   => '',
    );

    my $output = $mtf->render_file( 'konnitiwa.mt', { target => '異界' } )->as_string;
    is $output, "こんにちは、異界\n", 'utf8 bytes render ok';
    ok !utf8::is_utf8($output), 'utf8 bytes output ok';
};
