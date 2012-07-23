#!/usr/bin/perl -w

use strict;

use MemDiff;

unless(scalar @ARGV >= 2){
    print "\tUsage: $0 <data dir> <output dir>\n";
    exit;
}

setDataDir($ARGV[0]);
my($indir) = getDataDir();
my($outdir) = $ARGV[1];

# --- find the bounds ---
my($maxseg, $maxsnap) = indexData();
my(%pids) = getPids();

# --- diff only files that are actually different (size and md5 check) ---
my($j) = 0;
my($pid);

for $pid (keys %pids){
    system("mkdir -p $outdir/$pid");

    while($j <= $maxseg){
	my($i) = 1;
	my($lastsnap) = $i;

	my($out) = "$outdir/$pid/blockmods_seg$j";
	system("rm $out");

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

	    my($cmd) = "./memdiff $last $curr | awk \'{print $i \" \" \$1}\'>> $out";
	    print("$cmd\n");
	    system($cmd);

	    $lastsnap = $i;
	}

	$j++;
    }
}
