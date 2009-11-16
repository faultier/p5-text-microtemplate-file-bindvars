#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Benchmark qw(timethese cmpthese);
use Text::MicroTemplate::File;
use Text::MicroTemplate::File::BindVars;
use Text::MicroTemplate::Extended;
use Template;

my $count   = shift @ARGV || 1000;
my $cache   = shift @ARGV || 0;
my $wrapper = shift @ARGV || 0;

my $vars = {
    name      => 'faultier',
    age       => 24,
    favorites => {
        languages => [ 'Ruby',      'Perl',      'Objective-C' ],
        foods     => [ 'うどん', 'うどん', 'うどん', '裂けるチーズ' ],
    },
};

my $file = $wrapper ? 'wrapped' : 'test';

my $mt = undef;

sub mt {
    my %args = ( use_cache => $cache, include_path => [$Bin] );
    if ($cache) {
        $mt ||= Text::MicroTemplate::File->new(%args);
    }
    else {
        $mt = Text::MicroTemplate::File->new(%args);
    }
    $mt->render_file( $file . '.mt', $vars )->as_string;
}

my $mtb = undef;

sub mtb {
    my %args = ( use_cache => $cache, include_path => [$Bin] );
    if ($cache) {
        $mtb ||= Text::MicroTemplate::File::BindVars->new(%args);
    }
    else {
        $mtb = Text::MicroTemplate::File::BindVars->new(%args);
    }
    $mtb->render_file( $file . '.mtb', $vars )->as_string;
}

my $mte = undef;

# entends使ったときの動作がいまいち上手く行かない…
sub mte {
    my %args = (
        use_cache     => $cache,
        include_path  => [$Bin],
        template_args => $vars,
        extension     => '.mte'
    );
    if ($cache) {
        $mte ||= Text::MicroTemplate::Extended->new(%args);
    }
    else {
        $mte = Text::MicroTemplate::Extended->new(%args);
    }
    $mte->render($file)->as_string;
}

my $tt = undef;

sub tt {
    my %args = ( CACHE_SIZE => $cache ? undef : 0, INCLUDE_PATH => $Bin );
    if ($cache) {
        $tt ||= Template->new( \%args );
    }
    else {
        $tt = Template->new( \%args );
    }
    $tt->process( "$file.tt", $vars, \my $out ) or die $tt->error() . "\n";
}

my $comp = timethese(
    $count,
    {
        'T::MT::F'     => \&mt,
        'T::MT::F::BV' => \&mtb,
        'T::MT::E'     => \&mte,
        'TT'           => \&tt,
    }
);
cmpthese $comp;
