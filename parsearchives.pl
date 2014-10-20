#!/usr/bin/perl -w
use strict;
use MLDBM qw(DB_File Storable);
use Fcntl;

sub usage()
{
    print "gzip -cd /mounts/dist/full/full-head-x86_64/ARCHIVES.gz | $0\n";
    exit 0;
}

if(@ARGV) {usage}

my %dbdata;
my $dbm = tie %dbdata, 'MLDBM', "packages.mldbm", O_RDWR|O_CREAT, 0666;
my %data=();

while(<>) {
        next unless m{\./(.*)\.rpm:    (.*)};
        my ($pkg, $info)=($1, $2);
        next unless $pkg=~m{suse/([^/]+)/([^/]+)};
        my ($arch, $pkgname)=($1, $2);
        if ($info=~m/^Version\s*: (\S+)/) {$data{$pkgname}{version}=$1}
        if ($info=~m/^Release\s*: (\S+)/) {$data{$pkgname}{release}=$1}
        if ($info=~m/^Source RPM\s*: (\S+)\.rpm/) {
            my $src=$1;
            $src=~s/\.src$//;
            $src=~s/-[^-]+-[^-]+$//; # strip -version-release
            $data{$pkgname}{srcpkg}=$src;
        } elsif ($info=~m/^([dl-][r-][w-][x-][r-][w-][x-][r-][w-][x-])\s+(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\w{3}\s+\d+\s+[0-9:]+)\s+(.*)/) {
            my ($perm, $linkcount, $owner, $group, $size, $date, $file)=($1, $2, $3, $4, $5, $6, $7);
            if($perm=~m/^l/) { # is a link
                $file=~s/ -> .*//; # strip link target
            }
            $info="$file $perm $linkcount, $owner, $group, $size, $date";
            push(@{$data{$pkgname}{files}}, $file);
        }
        #print "$arch $pkgname $data{$pkgname}{srcpkg} $info\n";
}

print "writing out data...\n";
%dbdata=%data;
untie %dbdata;

#$a=$data{"4ti2-debuginfo"}{files}; print "@$a";
