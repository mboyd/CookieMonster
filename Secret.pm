#!/usr/bin/perl -W
package CookieMonster::Secret;
use strict;

use Digest::SHA qw(sha256_base64);

my $secretFile = "/etc/apache2/perl/CookieMonster/host_key";
my $secret;

sub secret {
	if ($secret) {
		return $secret;
	} else {
		open FILE, $secretFile or die "Can't open server secret: $!";
		my @key = <FILE>;
		$secret = sha256_base64(join(' ', @key));
	}
}

1;