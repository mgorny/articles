#!/usr/bin/env perl

use strict;
use warnings;

my @captions;

while (<>)
{
	chomp;
	my ($size, $caption) = split "\t";

	printf("(%s,{%s})\n", $size/1024, $caption);

	push @captions, $caption;
};

print "\n";

for my $c (@captions)
{
	printf("{%s},\n", $c);
};
