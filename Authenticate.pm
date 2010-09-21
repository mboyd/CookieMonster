#!/usr/bin/perl -W
package CookieMonster::Authenticate;
use strict;

use CookieMonster::AuthCert;
use CookieMonster::AuthForm;
use CookieMonster::Secret;

use CGI;
use Digest::SHA qw(sha256_base64);
use Apache2::Const qw(OK DECLINED FORBIDDEN);
use File::Basename;

# Fixme: Determine these paths automatically, or provide a better way to 
# configure them
my $docRoot = '/srv/www/';
my $tmplPrompt = 'include/login-prompt.html';
my $tmplSuccess = 'include/login-success.html';
my $tmplFailure = 'include/login-failure.html';

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
	my $hash = sha256_base64($user . $ip . CookieMonster::Secret::secret());

	my $token = {'user' => $user, 'ip' => $ip, 'hash' => $hash};
	my $cookie = CGI->cookie(-name=>'auth', -value=>$token);

	$r->print($resp->header("text/html", -cookie=>$cookie));
	
	my $redirect;
	if (my $dest = $resp->param('dest')) {
		my $target = ($resp->param('sec') eq '1' ? 'https://' : 'http://') . 
					$resp->server_name() . $dest;
		$redirect = "<meta http-equiv=\"Refresh\" content=\"1;url=$target\">";
	}
		
	printTemplate($r, $docRoot . $tmplSuccess, {'redirect' => $redirect});

	return OK;
}

sub failure {
	my $r = shift;
	
	printTemplate($r, $docRoot . $tmplFailure, {});
	
	return OK;
}

sub prompt {
	my $r = shift;
	my $resp = CGI->new($r);
	
	printTemplate($r, $docRoot . $tmplPrompt, {'dest' => $resp->param('dest'),
												'sec' => $resp->param('sec')});
	
	return OK;
}

sub printTemplate {
	my $r = shift;
	my $file = shift;
	my %env = %{(shift)};
	
	open TMPL, $file or die "Can't open $file";
	$r->content_type('text/html');
	
	while (<TMPL>) {
		$_ =~ s/\$(\w*)/$env{$1}/g;
		$r->print($_);
	}
}

1;
