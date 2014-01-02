use strict;
use warnings;
use Test::More;
use Symbol 'gensym';
use IPC::Open3;
use Storable;

my %s = ();
my %results;

for my $script (<script/*.pl>) {

    my $err = gensym;
    my $pid = open3( my $in, my $out, $err, $^X, $script ) or next;

    $s{$script} = {
        pid => $pid,
        cb  => sub {
            my ( $x, $y ) = ( 0, 0 );

            eval {
                local $SIG{ALRM} = sub { die "alarm" };
                alarm 1;
                print $in "@_\n";
                ( $y, $x ) = split / /, <$out>;
                alarm 0;
            };
            if ($@) {
                kill 'TERM', $pid;
                waitpid $pid, 0;
                $y = $x = 0;
            }
            return $y, $x;
          }
    };
}

for my $script ( keys %s ) {
    diag("Testing $script");
    my $s = $s{$script};
    for my $a (
        [ 5,  5 ],  [ 5,  10 ], [ 5,  15 ], [ 10, 5 ],
        [ 10, 15 ], [ 15, 5 ],  [ 15, 10 ], [ 15, 15 ]
      )
    {
        my $coord = [ 10, 10 ];
        my $success = 0;
        for my $i ( 1 .. 100 ) {
            my ( $t, $r, $b, $l ) = ( 0, 0, 0, 0 );
            my $ady = $a->[0] - $coord->[0];
            my $adx = $a->[1] - $coord->[1];
            $t = '@' if $ady == -1 && $adx == 0;
            $r = '@' if $ady == 0  && $adx == 1;
            $b = '@' if $ady == 1  && $adx == 0;
            $l = '@' if $ady == 0  && $adx == -1;
            my ( $dy, $dx ) = $s->{cb}->( $t, $r, $b, $l, $ady, $adx );

            if ( abs($dy) + abs($dx) != 1 ) {
                diag("incorrect step: $dx, $dy");
                last;
            }
            $coord->[0] += $dy;
            $coord->[1] += $dx;
            if ( $coord->[0] == $a->[0] && $coord->[1] == $a->[1] ) {
                $results{$script} += $i;
                $success = 1;
                last;
            }
        }
        ok $success, "eat apple";
    }
}

store \%results, 'golf-10-snake.out';

done_testing();
