package Beam::Emitter::Safe;

use strict;
use warnings;

use Moo::Role;
with 'Beam::Emitter';

sub emit {
    my ( $self, $name, %args ) = @_;
    my $class = delete $args{ class } || "Beam::Event";
    $args{ emitter  } = $self;
    $args{ name     } = $name;
    my $event = $class->new( %args );
    for my $listener ( @{ $self->_listeners->{$name} } ) {
        if ( $name eq 'error' ) {
            $listener->( $event );
            last if $event->is_stopped;
            next;
        }
        my $err;
        {
            local $@;
            eval { $listener->( $event ); 1 } or $err = $@;
        }
        $self->emit( 'error', class => "Beam::Event::Error", error => $err ) if defined $err;
        last if $event->is_stopped;
    }
    return $event;
}

sub emit_args {
    my ( $self, $name, @args ) = @_;
    for my $listener( @{ $self->_listeners->{$name} } ) {
        if ( $name eq 'error' ) {
            $listener->( @args );
            next;
        }
        my $err;
        {
            local $@;
            eval { $listener->( @args ); 1 } or $err = $@;
        }
        $self->emit_args( error => $err ) if defined $err;
    }
    return;
}

1;
