#!/usr/bin/perl

use warnings;
use strict;

binmode(STDOUT, ":encoding(UTF-8)");

use Audio::Scan qr/scan/;
local $ENV{AUDIO_SCAN_NO_ARTWORK} = 1;

sub convertMsToTime
{
	my $min = 0;
	my $sec = 0;

	my $ms = shift;
	while($ms > 60000)
	{
		$ms -= 60000;
		$min++;
	}
	while($ms > 1000)
	{
		$ms -= 1000;
		$sec++;
	}

	# Ensure there's a leading 0 on the number of seconds.
	$sec = sprintf("%02d", $sec);

	# Return value formatted MM:SS. Cute :).
	return "${min}:${sec}";
}

opendir(my $dh, $ARGV[0]) || die "What a boob. Directory FAIL! $!";
my @files = grep { /\.m4a|\.mp4/ } readdir($dh);

my ($tags, $length, $trackNr, $artist, $title, $album);
my $i=1;

foreach(@files)
{
	$tags = Audio::Scan->scan("$ARGV[0]/$_");
	$length = convertMsToTime(${tags}->{'info'}->{'song_length_ms'});

	$trackNr = ${tags}->{'tags'}->{'TRKN'} || $i;
	$trackNr =~ s{/.*}{};
	$title = ${tags}->{'tags'}->{'NAM'} || "Unknown Title";
	$artist = ${tags}->{'tags'}->{'ART'} || "Unknown Artist";

	print "${trackNr}.	${title} - ${artist}	${length}\n";

	$i++;
}

closedir($dh);
