package MemDiff;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(indexData setDataDir getDataDir getPids);


# bad, bad globals used
my($maxseg, $maxsnap) = (0,0);
my(%pids);
my($indir);

sub getDataDir{
    $indir;
}

sub setDataDir{
    my($dir) = @_;

    $indir = $dir;
}

sub getPids{
    %pids;
}

# --- find the bounds ---
sub indexData{
    opendir(INDIR, $indir) || die "can't opendir $indir: $!\n";

    while(readdir INDIR){
	if(/pid(\d+)_snap(\d+)_seg(\d+)/){
	    my($pid) = $1;
	    my($snap) = $2;
	    my($seg) = $3;

	    # don't actually need the test...
	    unless(defined $pids{$pid}){
		$pids{$pid} = 0;
	    }

	    if($snap > $maxsnap){
		$maxsnap = $snap;
	    }

	    if($seg > $maxseg){
		$maxseg = $seg;
	    }
	}elsif(/snap(\d+)_seg(\d+)/){
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


    unless((scalar (keys %pids)) > 0){
	$pids{""} = 0;
    }

    ($maxseg, $maxsnap);
}

# return true
1 == 1;
