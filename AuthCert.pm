#!/usr/bin/perl -W
package CookieAuth::AuthCert;
use strict;

# Attempt authentication from the specified request, returning a username
# if sucessful or undef otherwise
sub authenticate {
	my $r = shift;
	
	my $user = $r->subprocess_env('SSL_CLIENT_S_DN_Email');
	return unless $user =~ /\@MIT.EDU$/i;
	
	$user =~ s/\@MIT.EDU$//g;
	my @groups = split(' ', `groups $user`);

	my $validuser = 0;
	foreach (@groups) {
			if (/tv1e|tv1e-users/) {
					$validuser = 1;
					last;
			}
	}
	
	return ($validuser ? $user : '');
}

1;