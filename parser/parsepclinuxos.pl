#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "bzip2 -cd cache/pclinuxos/pkglist.x86_64.bz2 | $0 pclinuxossrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %srcmap;

my $in = \*STDIN;

while(1) { # one loop processes one package index entry
    my $head = "";
    read($in, $head, 16) or last;
    my ($x0, $x1, $heads, $size) = unpack("NNNN", $head);
    #print "$heads $x0 $x1 $size\n";
    my @heads=();
    for(my $i=0; $i<$heads; ++$i) {
        read($in, $heads[$i], 16) or die $!;
        $heads[$i] = [unpack("NNNN", $heads[$i])];
    }
    my $pkgdata = "";
    my %tags=();
    read($in, $pkgdata, $size) or die $!;
    for(my $i=0; $i<$heads; ++$i) {
        # tag, type, offs, type2?
        # https://pclinuxoshelp.com/index.php/Synaptic_and_the_Repositories
        #print "@{$heads[$i]}\n";
        my $datastart = $heads[$i][2];
        my $dataend = $heads[$i+1][2] || $size;
        if($heads[$i][3] == 1) {
            $tags{$heads[$i][0]} = substr($pkgdata, $datastart, $dataend-$datastart-1);
        }
    }
    #print "$tags{1000} $tags{1001} $tags{1002}\n";
    $srcmap{$tags{1000}} = $tags{1001};
}

dblib::init();
dblib::writehash("$target", \%srcmap);
