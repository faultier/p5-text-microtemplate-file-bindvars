#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Benchmark qw(timethese cmpthese);
use Text::MicroTemplate::File;
use Text::MicroTemplate::File::BindVars;
use Template;

my $count = shift @ARGV || 1000;
my $cache = shift @ARGV || 0;
my $wrapper = shift @ARGV || 0;

my $vars = {
    name      => 'faultier',
    age       => 24,
    favorites => {
        languages => [ 'Ruby',      'Perl',      'Objective-C' ],
        foods     => [ 'うどん', 'うどん', 'うどん', '裂けるチーズ' ],
    },
};

my $mt = undef;

sub mt {
    my %args = ( use_cache => $cache, include_path => $Bin );
    if ($cache) {
        $mt ||= Text::MicroTemplate::File->new(%args);
    }
    else {
        $mt = Text::MicroTemplate::File->new(%args);
    }
    my $result = $mt->render_file( $wrapper ? 'wrapped.mt' : 'test.mt', $vars )->as_string;
    warn $result if $count == 1;
}

my $mtb = undef;

sub mtb {
    my %args = ( use_cache => $cache, include_path => $Bin );
    if ($cache) {
        $mtb ||= Text::MicroTemplate::File::BindVars->new(%args);
    }
    else {
        $mtb = Text::MicroTemplate::File::BindVars->new(%args);
    }
    my $result = $mtb->render_file( $wrapper ? 'wrapped.mtb' : 'test.mtb', $vars )->as_string;
    warn $result if $count == 1;
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
    $tt->process( $wrapper ? 'wrapped.tt' : 'test.tt', $vars, \my $out ) or die $tt->error() . "\n";
    warn $out if $count == 1;
}

my $comp = timethese(
    $count,
    {
        'T::MT::F'     => \&mt,
        'T::MT::F::BV' => \&mtb,
        'TT'           => \&tt,
    }
);
cmpthese $comp;
