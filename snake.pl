use strict;
use warnings;
use lib 'lib';
use Snake;

my $s = Snake::Field->new;
$s->init;
$s->add_snake('human');
$s->show_snakes;
my @scores = $s->loop();
$s->end;

print "Your scores @scores\n";
