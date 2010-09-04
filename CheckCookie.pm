#!/usr/bin/perl -W
package CookieMonster::CheckCookie;

use strict;
use CGI;
use Digest::SHA qw(sha256_base64);
use Apache2::Const qw(DECLINED FORBIDDEN OK);

my $SECRET = 'TOPSECRET';

sub handler {
	my $r = shift;
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

	my $realHash = sha256_base64($user . $ip . $SECRET);
	unless ($realHash eq $hash) {
		$r->log_error("Bad hash.");
		return FORBIDDEN;
	}

	return OK;
}

1;

