#!/usr/bin/perl -W
package CookieMonster::AuthForm;
use strict;

use CGI;

# Attempt authentication from the specified request, returning a username
# if sucessful or undef otherwise
sub authenticate {
	my $r = shift;
	my $query = CGI->new($r);
	
	my $user = $query->param('username');
	my $pass = $query->param('password');
	
	if ($user eq 'firsteast' and $pass eq 'dancefuck1e') {
		return $user;
	} else {
		return;
	}
}

1;
