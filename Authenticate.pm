#!/usr/bin/perl -W
package CookieMonster::Authenticate;
use strict;

use CookieMonster::AuthCert;
use CookieMonster::AuthForm;

use CGI;
use Digest::SHA qw(sha256_base64);
use Apache2::Const qw(OK DECLINED FORBIDDEN);
use File::Basename;

# Fixme: Determine these paths automatically, or provide a better way to 
# configure them
my $docRoot = '/var/www/';
my $tmplPrompt = 'include/login-prompt.html';
my $tmplSuccess = 'include/login-success.html';
my $tmplFailure = 'include/login-failure.html';

my $SECRET = 'TOPSECRET';

sub handler {
	my $r = shift;
	my $query = CGI->new($r);
	
	if (my $user = CookieMonster::AuthCert::authenticate($r)) {
		return success($r, $user);
	
	} elsif ($r->method eq 'POST') {
		if (my $user = CookieMonster::AuthForm::authenticate($r)) {
			return success($r, $user);
		} else {
			return failure($r);
		}
		
	} else {
		return prompt($r);
	}
}

sub success {
	my ($r, $user) = @_;
	
	my $resp = CGI->new($r);
	
	my $ip = $r->connection->remote_ip;
	my $hash = sha256_base64($user . $ip . $SECRET);

	my $token = {'user' => $user, 'ip' => $ip, 'hash' => $hash};
	my $cookie = CGI->cookie(-name=>'auth', -value=>$token);

	$r->print($resp->header("text/html", -cookie=>$cookie));
	
	my $redirect;
	if (my $dest = $resp->param('dest')) {
		my $target = ($resp->param('sec') eq '1' ? 'https://' : 'http://') . 
					$resp->server_name() . $dest;
		$redirect = $resp->meta({-http_equiv=>'refresh', -content=>"1;$target"});
	}
		
	$r->print($resp->start_html(-head=>$redirect));
	$r->print(<<END
		<body>
			<div id="header">
				<h2>Welcome to Media1E!</h2>
				<img src="/auth/images/1E.png" alt="1E">
			</div>
		</body>
		</html>
END);

	return OK;
}

sub failure {
	my $r = shift;
	my $resp = CGI->new($r);
	
	$r->print($resp->header("text/html"));
	$r->print($resp->start_html("CookieAuth"));
	$r->print($resp->h2("Authentication Failed") . $resp->end_html);
	
	return OK;
}

sub prompt {
	my $r = shift;
	
	printHeader($r);
	
	$r->print(<<END
		<div id="body">
			<form method='post'>

				<span class='label'>Username:</span>
				<input type='text' name='username' value=''> <br>

				<span class='label'>Password:&nbsp;</span>
				<input type='password' name='password' value=''> <br>

				<span class='button'>
					<input type='submit' name='submit' value='Log In'>
				</span>
			</form>
			</div>
		</div>
	</body>
	</html>
END);
	
	return OK;
}

sub printHeader {
	my $r = shift;
	
	$r->print(<<END
		<!DOCTYPE html>
		<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
			<title>Welcome to Media1E</title>
			<link rel="stylesheet" href="/auth/style.css">
		</head>

		<body>
			<div id="header">
				<h2>Welcome to Media1E!</h2>
				<img src="/auth/images/1E.png" alt="1E">
			</div>
		
END
);	
}

1;
