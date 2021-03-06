#!/usr/bin/perl -W
package CookieMonster::CheckCookie;
use strict;

use CookieMonster::Secret;
use CGI;
use Digest::SHA qw(sha256_base64);
use Apache2::Const qw(DECLINED FORBIDDEN OK);

sub handler {
	my $r = shift;
	
	if ($r->connection->notes->get("cmAuthGood")) {
		# FIXME - This handler gets called way too many times.  To avoid
		# bringing the server to a crawl, we store a token indicating we've
		# already checked the cookie for this request.
		return OK;
	}
	
	my $cgi = CGI->new($r);

	my %token = $cgi->cookie('auth');
	unless (%token) { 
		return FORBIDDEN;
	}

	my $keys = $token{'user'};

	my $user = $token{'user'};
	my $ip = $token{'ip'};
	my $hash = $token{'hash'};

	my $reqIP = $r->connection->remote_ip;
	unless ($reqIP eq $ip) {
		$r->log_error("Wrong IP: Cookie for $ip but request from $reqIP");
		return FORBIDDEN;
	}

	my $realHash = sha256_base64($user . $ip . CookieMonster::Secret::secret());
	unless ($realHash eq $hash) {
		$r->log_error("Bad hash.");
		return FORBIDDEN;
	}
	
	$r->connection->notes->set("cmAuthGood" => 1);

	return OK;
}

1;

