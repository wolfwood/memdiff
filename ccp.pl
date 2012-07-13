#!/usr/bin/perl -w

use strict;

unless(scalar @ARGV >= 2){
		print "semantically-compressed recursive copy for memsnap data sets\n\n";
		print "\tUsage: $0 <data dir> <compressed clone dir>\n";
		exit;
}

my($indir) = $ARGV[0];
my($outdir) = $ARGV[1];

my($infile, $outfile);

# --- find the bounds ---
my($maxseg, $maxsnap) = (0,0);

opendir(INDIR, $indir) || die "can't opendir $indir: $!\n";

while(readdir INDIR){
		if(/snap(\d+)_seg(\d+)/){
				my($snap) = $1;
				my($seg) = $2;

				if($snap > $maxsnap){
						$maxsnap = $snap;
				}

				if($seg > $maxseg){
						$maxseg = $seg;
				}
		}

}

closedir INDIR;

print "$maxsnap $maxseg\n";


# --- diff only files that are actually different (size and md5 check) ---
my($j) = 0;

while($j < $maxseg){
		my($i) = 1;
		my($lastsnap) = $i;

		while($i < $maxsnap){
				$i++;

				my($curr) = "$indir/snap$i\_seg$j";
				my($last) = "$indir/snap$lastsnap\_seg$j";

				if((-s$curr) == (-s$last)){
						my($temp1) = split(/ /, `md5sum $curr`);
						my($temp2) = split(/ /, `md5sum $last`);
						if($temp1 eq $temp2){
								next;
						}
				}

				my($out) = "$outdir/seg$j\_snap$lastsnap\-$i";

				unless(-s$out){
						my($cmd) = "bsdiff $last $curr $out";
						print("$cmd\n");
						system($cmd);
				}

				$lastsnap = $i;
		}

		$j++;
}
