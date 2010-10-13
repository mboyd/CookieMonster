#!/usr/bin/perl -W
package CookieMonster::Public;
use strict;

use Apache2::Const qw(DECLINED FORBIDDEN OK);

sub handler {
	my $r = shift;
	
	return OK;
}

1;

