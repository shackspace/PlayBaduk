#!/usr/bin/perl
#
# play baduk data collection script
# hadez@nrrd.de / hadez@shackspace.de / @hdznrrd
# 

use LWP::Simple;

my $URL='http://play.baduk.org/go-test/start.php';


# name="PHPSESSID" value="0fa5921c10452455be16773a17395e9b"
#  Thank you! Your score is 92 from 200.
#  You are about European <b>16-kyu or lower

# game options we have for each question
my @options = (a..e);

srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip -f`);


# brute force approach
# generate all possible 20 character long strings of 'a' through 'e'.
# this doesn't work since it's 20^5 games
sub tree()
{
    my $branch = @_[0];

    if(length($branch) == 20)
    {
        &work($branch);
    }
    else {
        foreach my $item (@options)
        {
            &tree($branch.$item);
        }
    }
}

# generate random game sequences (20 char long random strings of 'a' through 'e')
sub random()
{
    foreach(1..5000) {
        my $branch = "";
        foreach(1..20) {
            $branch .= $options[rand($#options+1)];
        }
        &work($branch);
    }
}


# play a game based on the answer string supplied
sub work() {

    my $SESSION = "";
    my $PATH = $_[0];
    my $SCORE = 0;
    my $KYU = 0;
    
    my @task = split //,$PATH;
    local $| = 1;

    # output the path we're about to play
    print "$PATH ";
    

    # get inital problem which also includes the PHP session ID
    # which we have to pass to subsequent requests
    my $c = get($URL);
    $c =~ /PHPSESSID" value="([^"]+)"/m;
    $SESSION = $1;
    
    # answer each of the 20 questions
    foreach my $answer (@task) {
        print "."; # print status update
        $c = get("$URL?PHPSESSID=$SESSION&answer=$answer&submit=OK");
    }

    # now we should be done, if we're not, error out.
    if($c =~ /Your score is (\d+)/im) {
        $SCORE = $1;

        # this would even support -dan level results mapping them
        # to negative kyu levels.
        # however, the test doesn't cover -dan level results
        $c =~ /<b>(\d+)\-(\S+)/m;
        $KYU = $1;

        if($2 ne "kyu")
        {
            $KYU * -1;
        }
        
        #output the final score and kyu level
        print " $SCORE $KYU\n";
    }
    else
    {
        print "failed\n";
    }

}


&random("");
