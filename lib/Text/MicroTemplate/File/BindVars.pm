package Text::MicroTemplate::File::BindVars;

use warnings;
use strict;
use base qw(Text::MicroTemplate::File);
use Carp qw(croak);

our $VERSION = '0.01';

sub build_file {
    my ( $self, $file, @vars ) = @_;
    my $cache_key = join( '::', $file, @vars );

    # return cached entry
    if ( $self->{use_cache} == 2 ) {
        if ( my $e = $self->{cache}->{$cache_key} ) {
            return $e->[1];
        }
    }

    # iterate
    foreach my $path ( @{ $self->{include_path} } ) {
        my $filepath = $path . '/' . $file;
        if ( my @st = stat $filepath ) {
            if ( my $e = $self->{cache}->{$cache_key} ) {
                return $e->[1]
                  if $st[9] == $e->[0];
            }
            open my $fh, "<$self->{open_layer}", $filepath
              or croak "failed to open:$filepath:$!";
            my $src = do { local $/; join '', <$fh> };
            close $fh;
            $self->parse($src);
            my $setter = 'my $_mt = shift;';
            $setter .= join( '', map { "my \$$_ = shift;" } @vars );
            local $Text::MicroTemplate::_mt_setter = $setter;
            my $f = $self->build();
            $self->{cache}->{$cache_key} = [ $st[9], $f, ] if $self->{use_cache};
            return $f;
        }
    }
    die "could not find template file: $file\n";
}

sub render_file {
    my $self = shift;
    my $file = shift;
    my $partial;

    if ( ref( $_[0] ) eq 'Text::MicroTemplate::EncodedString' ) {
        $partial = shift;
    }

    if ( ref( $_[0] ) eq 'HASH' ) {
        my $bind_params = $_[0];
        $bind_params->{partial} = $partial if $partial;
        $self->build_file( $file, keys %$bind_params )->( $self, values %$bind_params );
    }
    elsif ($partial) {
        $self->build_file( $file, 'partial' )->( $self, $partial );
    }
    else {
        $self->build_file( $file )->( $self, @_);
    }
}

1;

__END__

=head1 NAME

Text::MicroTemplate::File::BindVars - The great new Text::MicroTemplate::File::BindVars!

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Text::MicroTemplate::File::BindVars;

    my $mtb  = Text::MicroTemplate::File::BindVars->new();
    my $html = $mtb->render_file('hello.mt', { foo => 'bar' })->as_string;


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 build_file

=cut

=head2 render_file

=cut

=head1 AUTHOR

Taro Sako, C<< <roteshund+cpan at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Taro Sako.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Text::MicroTemplate::File::BindVars
