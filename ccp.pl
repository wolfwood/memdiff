#!/usr/bin/perl -w

use strict;

use MemDiff;

use Jobs;

setMaxJobs(20);

unless(scalar @ARGV >= 2){
		print "semantically-compressed recursive copy for memsnap data sets\n\n";
		print "\tUsage: $0 <data dir> <compressed clone dir>\n";
		exit;
}

setDataDir($ARGV[0]);

my($indir) = getDataDir();
my($outdir) = $ARGV[1];

my($infile, $outfile);

# --- find the bounds ---
my($maxseg, $maxsnap) = indexData();
print "$maxsnap $maxseg\n";
my(%pids) = getPids();

# --- diff only files that are actually different (size and md5 check) ---
my($j) = 0;
my($pid);

for $pid (keys %pids){
		system("mkdir -p $outdir/$pid");

		while($j <= $maxseg){
				my($i) = 1;
				my($lastsnap) = $i;

				while($i < $maxsnap){
						$i++;

						my($curr) = "$indir/snap$i\_seg$j";
						my($last) = "$indir/snap$lastsnap\_seg$j";

						unless($pid eq ""){
								$curr = "$indir/pid$pid\_snap$i\_seg$j";
								$last = "$indir/pid$pid\_snap$lastsnap\_seg$j";
						}

						if((-s$curr) == (-s$last)){
								my($temp1) = split(/ /, `md5sum $curr`);
								my($temp2) = split(/ /, `md5sum $last`);
								if($temp1 eq $temp2){
										next;
								}
						}

						my($out) = "$outdir/$pid/seg$j\_snap$lastsnap\-$i";

						unless(-s$out){
								my($cmd) = "bsdiff $last $curr $out";
								print("$cmd\n");
								enqueueJob($cmd);
						}

						$lastsnap = $i;
				}

				$j++;
		}
}

drainQueue();
