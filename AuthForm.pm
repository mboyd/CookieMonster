#!/usr/bin/perl -W
package CookieMonster::AuthForm;
use strict;

use CGI;
use Digest::SHA qw(sha256_base64);

my $PASSWORD = 'L9hIRi0owLjMNSr8p05e6b4y8fWOb7KhAYBEWxGJkGo';
# Yeah, yeah, static passwords and all that.
# TDOD: Make this not a sketchy hack.

# Attempt authentication from the specified request, returning a username
# if sucessful or undef otherwise
sub authenticate {
	my $r = shift;
	my $query = CGI->new($r);
	
	my $user = $query->param('username');
	my $pass = sha256_base64($query->param('password'));
	
	if ($user eq 'firsteast' and $pass eq $PASSWORD) {
		return $user;
	} else {
		return;
	}
}

1;
