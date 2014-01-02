use strict;
use warnings;
use Test::More;
use Symbol 'gensym';
use IPC::Open3;
use Storable;
use Snake;
use Data::Dumper;

my %s = ();
my $results = retrieve 'golf-10-snake.out';
my @snakes = sort keys %$results;

my $start = sub {

    my %pids;
    my $s = Snake::Field->new;
    $s->init;

    for my $script (@snakes) {

        my $err = gensym;
        my $pid = open3( my $in, my $out, $err, $^X, $script ) or next;

        $pids{$pid} = 1;
        $s->add_snake( sub{
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
                    delete $pids{$pid};
                }
                return $y, $x;
        });
    }

    $s->show_snakes;
    my @scores = $s->loop();
    $s->end;
    for (keys %pids) {
        kill 'TERM', $_;
        waitpid $_,0 ;
    }
    return @scores;
};

my $count = 10;
my $fights = {};
for (1..$count) {
    my @res = $start->();
    for (0..@snakes-1) {
        $fights->{ $snakes[$_] } += $res[$_]/$count;
    }
}

store $fights, 'golf-10-snake-fight.out';
