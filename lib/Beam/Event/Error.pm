package Beam::Event::Error;

use strict;
use warnings;

use Moo;
extends 'Beam::Event';

has 'error' => (
    is => 'ro',
    required => 1,
);

1;
