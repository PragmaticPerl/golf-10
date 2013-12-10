use strict;
use warnings;
use lib 'lib';
use Snake;
use Symbol 'gensym';
use IPC::Open3;

my $s = Snake::Field->new;
$s->init;
my @scripts = ();

for my $script (<script/*.pl>) {

    my $err = gensym;
    my $pid = open3( my $in, my $out, $err, $^X, $script ) or die $!;

    my $cb = sub {
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
    };
    push @scripts, $pid;
    $s->add_snake($cb);
}

$s->add_snake('human');
$s->show_snakes;
my @scores = $s->loop();
$s->end;
kill 'TERM', $_ for @scripts;

print "Scores: @scores\n";
