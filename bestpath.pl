#!/usr/bin/perl
#
# calculate best possible game/answer path based on captured data
# hadez@nrrd.de / hadez@shackspace.de / @hdznrrd
#


my @good = ();
my %histo = ();

# only consider results that have a score higher or equal to this number
my $cutoff = 120;

my $samples = 0;
while(<>)
{
    if(/^(\S+) \S+ (\d+) (\d+)$/)
    {

        next if($2 <= $cutoff);

        $samples++;

        @ans = split //, $1;
        foreach my $ians (0..$#ans)
        {
            $histo{$ans[$ians]}[$ians] += $2-$cutoff;
        }
    }
}

# do scaling to (0..1) on a per-column basis
# this will ensure that you'll get the most  likely to be correct
# answer for each game step as '1.0' and all others with values
# less than that
my @max = ();
foreach my $level (0..19)
{
    foreach my $ans ('a'..'e')
    {
        $max[$level] = $histo{$ans}[$level]
          if($max[$level] < $histo{$ans}[$level])
    }
}

# print header, the first number is the number of actually considered samples
printf("%3d",$samples);
printf(" %3d",$_+1) foreach(0..19);
print "\n-------------------------------------------------------------------------------------\n";

foreach my $ans ('a'..'e')
{
    printf(" %s: ",$ans);
    foreach my $level (0..19)
    {
        printf(" %.1f",$histo{$ans}[$level]/$max[$level]);
    }
    print "\n";
}
