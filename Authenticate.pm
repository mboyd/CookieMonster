#!/usr/bin/perl -W
package CookieAuth::Authenticate;
use strict;

use CookieAuth::AuthCert;
use CookieAuth::AuthForm;

use CGI;
use Digest::SHA qw(sha256_base64);
use Apache2::Const qw(OK DECLINED FORBIDDEN);

my $SECRET = 'TOPSECRET';

sub handler {
	my $r = shift;
	my $query = CGI->new($r);
	
	if (my $user = CookieAuth::AuthCert::authenticate($r)) {
		return success($r, $user);
	
	} elsif ($r->method eq 'POST') {
		if (my $user = CookieAuth::AuthForm::authenticate($r)) {
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
	$r->print($resp->h2("Authentication Sucessful") . $resp->end_html);

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
	my $resp = CGI->new($r);
	
	$r->print($resp->header("text/html"));
	$r->print($resp->start_html("CookieAuth"));
	$r->print($resp->h2("Authentication Prompt"));
	
	$r->print($resp->start_form());
	$r->print($resp->hidden('dest', $resp->param('dest')));
	$r->print($resp->hidden('sec', $resp->param('sec')));
	$r->print($resp->textfield('user', 'Username', 20, 20));
	$r->print($resp->password_field('pass', '', 20, 20));
	$r->print($resp->submit('Submit', 'submit'));
	$r->print($resp->end_form);
	
	$r->print($resp->end_html);
	
	return OK;
}

1;
