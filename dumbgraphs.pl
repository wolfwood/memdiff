#!/usr/bin/perl -w

use strict;

unless(scalar @ARGV >= 1){
		print "make graphs from a ccp.pl'ed data set\n\n";
		print "\tUsage: $0 <data dir>\n";
		exit;
}

my($indir) = $ARGV[0];

# --- collect the diff sizes ---
my($maxseg, $maxsnap) = (0,0);

opendir(INDIR, $indir) || die "can't opendir $indir: $!\n";

my(%sizesForSegs);

while(readdir INDIR){
		if(/seg(\d+)_snap(\d+)-(\d+)/){
				my($seg) = $1;
				my($snap) = $2;

				if($snap > $maxsnap){
						$maxsnap = $snap;
				}

				if($seg > $maxseg){
						$maxseg = $seg;
				}

				my(@size) = split(/ /, `ls -l $indir/$_`);
				my($size) = $size[4];

				unless(defined $sizesForSegs{$seg}){
						$sizesForSegs{$seg} = {};
				}

				#print "$seg $snap $size\n";

				$sizesForSegs{$seg}{$snap} = $size;
		}

}

closedir INDIR;

print "$maxsnap $maxseg\n";

my($seg, $snap);

for $seg (sort {$a <=> $b} keys %sizesForSegs){
		open(OUT, ">$indir/size$seg");

		for $snap (sort {$a <=> $b} keys $sizesForSegs{$seg}){
				print OUT "$snap $sizesForSegs{$seg}{$snap}\n";
		}

		close OUT;
}


# --- GnuPlot! ---
my($scriptfile) = "$indir/dumbscript.gp";
open(SCRIPT, ">$scriptfile") || die "error opening gnuplot script file: $!";

my($graphType) = "png";

if($graphType eq "eps"){
				print SCRIPT "set term postscript enhanced color\n";
}elsif($graphType eq "svg"){
				print SCRIPT "set term svg\n";
}elsif($graphType eq "png"){
				print SCRIPT "set term png large\n";
				#print SCRIPT "set size 2,2\n";
}else{
				print SCRIPT "set term x11\n";
}

my($title) = "Memory modifications over time";

print SCRIPT "set title \"$title\"\n";
print SCRIPT "set xlabel \"Snapshot Sequence Number\"\n";
print SCRIPT "set ylabel \"Diff Size in Bytes\"\n";

#print SCRIPT "set key bottom left\n";

print SCRIPT "set autoscale x\n";
print SCRIPT "set logscale y\n";

#print SCRIPT "f(x,q) = q\n";

print SCRIPT "plot ";

my($i) = 0;

for $seg (sort {$a <=> $b} keys %sizesForSegs){
#for $seg (4,7){

		my($datafile) = "$indir/size$seg";

		if(-e $datafile){
				$title = "seg $seg";

				if($i == 0){
						$i = 1;
				}else{
						print SCRIPT ", ";
				}

				print SCRIPT "\"$datafile\" title \"$title\" with linespoints";
		}
}

#print SCRIPT "f(x, $compulsory) title \"compulsory\" with lines\n";

close SCRIPT;

system("gnuplot < $scriptfile > $indir/dumgraf\.$graphType");


# --- individual ---
for $seg (sort {$a <=> $b} keys %sizesForSegs){
		my($scriptfile) = "$indir/dumbscript$seg.gp";
		open(SCRIPT, ">$scriptfile") || die "error opening gnuplot script file: $!";

		my($graphType) = "png";

		if($graphType eq "eps"){
				print SCRIPT "set term postscript enhanced color\n";
		}elsif($graphType eq "svg"){
				print SCRIPT "set term svg\n";
		}elsif($graphType eq "png"){
				print SCRIPT "set term png large\n";
				#print SCRIPT "set size 2,2\n";
		}else{
				print SCRIPT "set term x11\n";
		}

		my($title) = "Memory modifications to Seg $seg over time";

		print SCRIPT "set title \"$title\"\n";
		print SCRIPT "set xlabel \"Snapshot Sequence Number\"\n";
		print SCRIPT "set ylabel \"Diff Size in Bytes\"\n";

#print SCRIPT "set key bottom left\n";

		print SCRIPT "set autoscale x\n";
		print SCRIPT "set autoscale y\n";

#print SCRIPT "f(x,q) = q\n";

		print SCRIPT "plot ";

		my($datafile) = "$indir/size$seg";

		$title = "seg $seg";
		print SCRIPT "\"$datafile\" title \"$title\" with linespoints";

#print SCRIPT "f(x, $compulsory) title \"compulsory\" with lines\n";

		close SCRIPT;

		system("gnuplot < $scriptfile > $indir/dumgraf$seg\.$graphType");
}
