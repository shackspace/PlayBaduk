#!/usr/bin/perl
#
# calcualte basic statistics on data gathered from random-walking the play.baduk.org test
# hadez@nrrd.de / hadez@shackspace.de / @hdznrrd


# width of the histogram display
my $scale = 68;


my %stats = ();
my $samples = 0;

# collect all kyu scores and build a histogram
while(<>)
{
    if(/\S+ \S+ (\d+) ([-]?\d+)/)
    {
        $stats{$2}++;
        $samples++;
    }
}

my @keys = sort { $a <=> $b } keys %stats;
my @values = sort {$a <=> $b } values %stats;
my $kmin = $keys[0];
my $kmax = $keys[$#keys];
my $vmin = $values[0];
my $vmax = $values[$#values];

# build a cummulative histogram
my %cummulative = ();
map { $cummulative{$_} = $cummulative{$_-1} + $stats{$_} } ($kmin..$kmax);

# calcualte the mean kyu
my $ksum = 0;
map { $ksum += $_ * $stats{$_} } ($kmin..$kmax);
my $kmean = $ksum / $samples;

# calculate the median kyu
my $kmedian = 0;
map { $kmedian = $_ if($cummulative{$_} <= $samples/2) } ($kmin..$kmax);


print "baduk online skill level estimator\nkyu distribution of random walk\n\n";

# print histogram
print map { 
    sprintf("%2d %s (%d)\n"
        ,$_
        ,"=" x int($stats{$_}/$vmax*$scale)
        , $stats{$_} ) 
} ($kmin..$kmax);

#output basic stats
printf ("\nsamples: %d     mean kyu: %f    median kyu: %d\n\n",$samples,$kmean,$kmedian);


