#!/usr/bin/perl
use strict;
use warnings;
use PPI;
use JSON::Syck;

my $source = join ('', <STDIN>, "\n");

my @res;

for my $token (@{PPI::Document->new(\$source)->find(q{PPI::Token})}) {
    my $item = [ ref $token, $token->content.q() ];
    push @res, $item;
}

print JSON::Syck::Dump [ @res ];
