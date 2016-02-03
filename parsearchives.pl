#!/usr/bin/perl -w
use strict;
use dblib;

sub usage()
{
    print "gzip -cd /mounts/dist/full/full-head-x86_64/ARCHIVES.gz | $0\n";
    exit 0;
}

if(@ARGV) {usage}

my %data;
my %filepkgmap;
my %pkgsrcmap;
my %binpath=qw(/bin 1 /sbin 1 /usr/bin 1 /usr/sbin 1);

open(APPARMORFD, ">", "db/apparmor-list.txt");

while(<>) {
    next unless m{\./(.*)\.rpm:    (.*)};
    my ($pkg, $info)=($1, $2);
    next unless $pkg=~m{suse/([^/]+)/([^/]+)};
    my ($arch, $pkgname)=($1, $2);
    if ($info=~m/^Version\s*: (\S+)/) {$data{$pkgname}{version}=$1}
    if ($info=~m/^Release\s*: (\S+)/) {$data{$pkgname}{release}=$1}
    if ($info=~m/^Source RPM\s*: (\S+)-[^-]+-[^-]+\.\w+\.rpm$/) {
        $pkgsrcmap{$pkgname}=$1;
        $data{$pkgname}{srcpkg}=$1;
    } elsif ($info=~m/^([dl-][r-][w-][x-][r-][w-][x-][r-][w-][x-])\s+(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\w{3}\s+\d+\s+[0-9:]+)\s+(.*)/) {
        my ($perm, $linkcount, $owner, $group, $size, $date, $file)=($1, $2, $3, $4, $5, $6, $7);
        if($perm=~m/^l/) { # is a link
            $file=~s/ -> .*//; # strip link target
        }
        push(@{$filepkgmap{$file}}, $pkgname);
        if($perm=~/^-rwx/ && $file!~m{/usr/lib/debug} && 
          $file=~m{(.*bin)/([^/]+)$} && !$binpath{$1}) {
            my($p,$f)=($1,$2);
            $filepkgmap{"/xbin/$f"}=$pkgname;
            #print "found executable in $p / $f\n";
        }
        if($file=~m{^/etc/apparmor|^/usr/share/apparmor|^/etc/apparmor.d}) {
            print APPARMORFD "$file=$pkgname\n";
        }
        #push(@{$data{$pkgname}{files}}, $file);
        #$info="$file $perm $linkcount, $owner, $group, $size, $date";
    }
    #print "$arch $pkgname $pkgsrcmap{$pkgname} $info\n";
}

dblib::init();
dblib::writehash("filepkg.dbm", \%filepkgmap);
dblib::writehash("pkgsrc.dbm", \%pkgsrcmap);
