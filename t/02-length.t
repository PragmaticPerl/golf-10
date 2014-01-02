use strict;
use warnings;
use Test::More;
use Storable;

my $results = retrieve 'golf-10-snake.out';
my $fights  = retrieve 'golf-10-snake-fight.out';

my $min    = 1e9;
my @winner = ('nobody');

for my $script (<script/*.pl>) {
    unless ( defined $results->{$script} ) {
        $script =~ s/script\///;
        diag( sprintf "% 20s: failed tests, skipped", $script );
        next;
    }

    local ( *FILE, $/ );
    open FILE, '<', $script or BAIL_OUT();
    local $_ = <FILE>;
    s/\#! ?\S+\s?// if /^\#!/;
    s/\s*\z//;
    my $length       = length($_);
    my $points       = $results->{$script};
    my $fight_points = $fights->{$script};

    $script =~ s/script\///;
    diag( sprintf "% 20s: length=% 3s, path=%3d, fights=%3d",
        $script, $length, $points, $fight_points );
    pass();

    if ( $min > $length + $points ) {
        @winner = ($script);
        $min    = $length + $points;
    }
    elsif ( $min == $length + $points ) {
        push @winner, $script;
    }
}

diag( "And the oscar goes to " . join ", ", @winner );

done_testing();
