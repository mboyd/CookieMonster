#!/usr/bin/perl -W
package CookieAuth::AuthForm;
use strict;

use CGI;

# Attempt authentication from the specified request, returning a username
# if sucessful or undef otherwise
sub authenticate {
	my $r = shift;
	my $query = CGI->new($r);
	
	my $user = $query->param('user');
	my $pass = $query->param('pass');
	
	$r->log_error("Attempted login from $user with $pass");
	
	if ($user eq 'firsteast' and $pass eq 'dancefuck1e') {
		return $user;
	} else {
		return;
	}
}

1;