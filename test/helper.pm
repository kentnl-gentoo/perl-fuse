#!/usr/bin/perl
package test::helper;
use strict;
use Exporter;
use Config;
use POSIX qw(WEXITSTATUS);
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
@ISA = "Exporter";
@EXPORT_OK = qw($_loop $_point $_pidfile $_real);
my $tmp = -d '/private' ? '/private/tmp' : '/tmp';
our($_loop, $_point, $_pidfile, $_real) = ("","$tmp/fusemnt-".$ENV{LOGNAME},"test/s/mounted.pid","$tmp/fusetest-".$ENV{LOGNAME});
#$_loop = $^O ne 'darwin' && $Config{useithreads} ? "examples/loopback_t.pl" : "examples/loopback.pl";
$_loop = $Config{useithreads} ? "examples/loopback_t.pl" : "examples/loopback.pl";
if($0 !~ qr|s/u?mount\.t$|) {
	my ($reject) = 1;
	if(open my $fh, '<', $_pidfile) {
		my $pid = do {local $/ = undef; <$fh>};
		close $fh;
		if(kill 0, $pid) {
			if(`mount` =~ m{on (?:/private)?$_point }) {
				$reject = 0;
			} else {
				kill 1, $pid;
			}
		}
	}
	system("ls $_point >/dev/null");
	$reject = 1 if (POSIX::WEXITSTATUS($?));
	die "not properly mounted\n" if $reject;
}
1;
