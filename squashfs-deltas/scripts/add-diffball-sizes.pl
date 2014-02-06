#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
$\ = "\n";

while (<>)
{
	chomp;
	my ($size, $date1, $date2, $sumsize) = split "\t";

	my $dsize;
	if ($size eq 'size')
	{
		$dsize = 'difflen';
	}
	else
	{
		my $rawdate1 = $date1;
		$rawdate1 =~ s/-//g;
		my $rawdate2 = $date2;
		$rawdate2 =~ s/-//g;

		my $url = "http://distfiles.gentoo.org/snapshots/deltas/snapshot-$rawdate1-$rawdate2.patch.bz2";
		my $r = $ua->head($url);
		$dsize = $r->header('Content-Length');
	}

	print join("\t", ($size, $date1, $date2, $sumsize, $dsize));
}
