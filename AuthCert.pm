#!/usr/bin/perl -W
package CookieMonster::AuthCert;
use strict;

# Attempt authentication from the specified request, returning a username
# if sucessful or undef otherwise
sub authenticate {
	my $r = shift;

	my $user = $r->subprocess_env('SSL_CLIENT_S_DN_Email');
	$user =~ s/\@MIT\.EDU$//i; # strip @mit.edu from MIT certs

	return unless $user;

	my $aclFile = "/etc/apache2/perl/CookieMonster/cert_acl";
	open(ACL, "<", $aclFile) or do { warn "Failed to open $aclFile: $!"; return '' };
	my @users = <ACL>;
	close(ACL);
	chomp @users;

	my $validuser = grep { $_ eq $user } @users;

	return ($validuser ? $user : '');
}

1;
