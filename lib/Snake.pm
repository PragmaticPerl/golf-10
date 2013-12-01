package Snake;
use strict;
use warnings;
no warnings 'numeric';
use Curses;

sub new {
    my $self = bless { snake => [], dir => [ 0, 1 ] }, shift;
    my %arg  = @_;
    my $y    = $arg{y} || 1;
    my $x    = $arg{x} || 1;
    $self->{color} = $arg{color} || 1;
    $self->{char}  = $arg{char}  || 1;
    $self->{cb}    = $arg{cb}    || 'human';
    push @{ $self->{snake} },
      [ $y, $x ],
      [ $y, $x + 1 ],
      [ $y, $x + 2 ],
      [ $y, $x + 3 ],
      [ $y, $x + 5 ];
    return $self;
}

my @char =
  ( '*', '#', '~', '=', '-', '.', ':', '/', '|', '\\', '!', '^', '%', '$',
    '?' );

sub char {
    $char[ shift->{char} - 1 ];
}

sub show {
    my ( $self, $win ) = @_;
    for ( @{ $self->snake } ) {
        $win->attron( COLOR_PAIR( $self->{color} ) );
        $win->addstr( $_->[0], $_->[1], $self->char );
    }
}

sub cb {
    shift->{cb};
}

sub snake {
    shift->{snake};
}

sub direction {
    my $self = shift;
    $self->{dir} = [@_] if @_;
    @{ $self->{dir} };
}

sub dead {
    my $self = shift;
    $self->{dead} = 1 if @_;
    exists $self->{dead};
}

sub grow {
    my $self  = shift;
    my $count = shift || 5;
    my $snake = $self->snake;
    my @c     = @{ $snake->[0] };
    for ( 1 .. $count ) {
        unshift @$snake, [@c];
    }
}

sub go {
    my ( $self, $win, $dy, $dx ) = @_;
    my $s = $self->snake;
    my $c = shift @$s;
    $win->addstr( @$c, " " );
    my @xy = @{ $s->[-1] };
    $xy[0] += $dy;
    $xy[1] += $dx;
    push @$s, [@xy];
    $win->attron( COLOR_PAIR( $self->{color} ) );
    $win->addstr( @xy, $self->char );
    $win->move(@xy);
}

package Snake::Field;
use strict;
use warnings;
no warnings 'numeric';

use Curses;
use Carp;

sub new {
    my $class = shift;
    bless {
        row    => 0,
        col    => 0,
        win    => undef,
        snakes => [],
        count  => 0
    }, $class;
}

sub init {
    my $self = shift;
    my $win = $self->{win} = Curses->new();
    raw();
    noecho();
    start_color();
    init_pair( 1, COLOR_GREEN,   COLOR_BLACK );
    init_pair( 2, COLOR_RED,     COLOR_BLACK );
    init_pair( 3, COLOR_BLUE,    COLOR_BLACK );
    init_pair( 4, COLOR_YELLOW,  COLOR_BLACK );
    init_pair( 5, COLOR_MAGENTA, COLOR_BLACK );
    init_pair( 6, COLOR_CYAN,    COLOR_BLACK );
    init_pair( 7, COLOR_WHITE,   COLOR_BLACK );
    $win->attron( COLOR_PAIR(1) );
    $win->keypad(1);
    $win->getmaxyx( my $row, my $col );

    if ( $row < 10 || $col < 10 ) {
        croak "window is too small";
    }
    else {
        $self->{row} = $row;
        $self->{col} = $col;
    }
    $win->box( 0, 0 );
}

sub win {
    shift->{win};
}

sub add_snake {
    my ( $self, $cb ) = @_;

    my $r = int( $self->{row} / 2 );
    my $c = int( $self->{col} / 2 );
    $self->{count}++;
    croak "too many snakes (max 7)" if ( $self->{count} > 7 );

    push $self->{snakes},
      Snake->new(
        y     => $r - 12 + 3 * $self->{count},
        x     => $c - 2,
        color => $self->{count},
        char  => $self->{count},
        cb    => $cb,
      );
}

sub show_snakes {
    my $self = shift;
    my $win  = $self->win;
    for my $snake ( @{ $self->{snakes} } ) {
        $snake->show($win);
    }
}

sub put_apple {
    my $self = shift;
    my $win  = $self->win;
    my ( $x, $y );
    do {
        $y = int rand( $self->{row} - 2 ) + 1;
        $x = int rand( $self->{col} - 2 ) + 1;
      } while (
        grep { $_->[0] == $y && $_->[1] == $x }
        map { @{ $_->snake } } @{ $self->{snakes} }
      );
    $win->attron( COLOR_PAIR(2) );
    $win->addstr( $y, $x, "@" );
    $self->{apple} = [ $y, $x ];
    $win->attron( COLOR_PAIR(1) );
}

sub gameover {
    my $self = shift;
    my $win  = $self->win;
    $win->attron( COLOR_PAIR(2) );
    $win->addstr(
        int( $self->{row} / 2 ),
        int( $self->{col} / 2 - 4 ),
        "GAME OVER"
    );
    $win->attron( COLOR_PAIR(1) );
    $win->refresh;
    halfdelay(100);
    $win->getch();
}

sub collision {
    my ( $self, $snake, $dy, $dx ) = @_;
    my $win = $self->win;
    my $c   = $snake->snake->[-1];

    my $sym = $win->inch( $c->[0] + $dy, $c->[1] + $dx ) & A_CHARTEXT;

    return
        ( $sym == 0 || $sym == ord(' ') ) ? 1
      : ( $sym == ord('@') ) ? -1
      :                        0;
}

sub loop {
    my $self = shift;
    my $win  = $self->win;
    my $ch;
    $self->put_apple;

    my $snakes = $self->{snakes};

    halfdelay(1);
    my $loop     = 0;
    my $max_loop = 500;
    my $alive    = @$snakes;
    my $human    = grep { !ref $_ && $_ eq 'human' } map { $_->cb } @$snakes;

  LOOP:
    while ( $alive && $loop < $max_loop ) {

        if ( ( $loop++ % 10 == 0 ) || $human ) {
            $ch = $win->getch;
            if ( $ch eq 'Q' || $ch eq 'q' ) {
                last;
            }
            elsif ( $ch == KEY_RESIZE ) {
                $win->getmaxyx( $self->{row}, $self->{col} );
                $win->clear;
                $win->box( 0, 0 );
                $self->show_snakes;
                $self->put_apple;
            }
        }

        for ( my $i = 0 ; $i < @$snakes ; $i++ ) {
            my $snake = $snakes->[$i];
            next if $snake->dead;

            my @move = my @dir = $snake->direction;
            my $cb   = $snake->cb;
            my $c    = $snake->snake->[-1];
            my @data = ();

            if ( !ref $cb && $cb eq 'human' ) {

                if ( $ch == KEY_UP ) {
                    @move = ( -1, 0 ) if $dir[0] != 1;
                }
                elsif ( $ch == KEY_DOWN ) {
                    @move = ( 1, 0 ) if $dir[0] != -1;
                }
                elsif ( $ch == KEY_LEFT ) {
                    @move = ( 0, -1 ) if $dir[1] != 1;
                }
                elsif ( $ch == KEY_RIGHT ) {
                    @move = ( 0, 1 ) if $dir[1] != -1;
                }
                elsif ( $ch == ERR ) {
                }
                else {
                    $snake->dead(1);
                    $alive--;
                    $human = 0;
                    next;
                }
            }
            else {
                for my $yx ( [ -1, 0 ], [ 0, 1 ], [ 1, 0 ], [ 0, -1 ] ) {
                    my $sym =
                      $win->inch( $c->[0] + $yx->[0], $c->[1] + $yx->[1] ) &
                      A_CHARTEXT;
                    $sym =
                        ( $sym == ord('@') ) ? '@'
                      : ( $sym == ord(' ') || $sym == 0 ) ? '0'
                      :                                     '#';
                    push @data, $sym;
                }

                my $a = $self->{apple};
                push @data, $a->[0] - $c->[0], $a->[1] - $c->[1];
                eval { @move = $cb->(@data) };
                if ( $@ || !defined $move[0] || !defined $move[1] ) {
                    $snake->dead(1);
                    $alive--;
                    next;
                }

                if ( $move[0] == -1 ) {
                    @move = ( -1, 0 ) if $dir[0] != 1;
                }
                elsif ( $move[0] == 1 ) {
                    @move = ( 1, 0 ) if $dir[0] != -1;
                }
                elsif ( $move[1] == -1 ) {
                    @move = ( 0, -1 ) if $dir[1] != 1;
                }
                elsif ( $move[1] == 1 ) {
                    @move = ( 0, 1 ) if $dir[1] != -1;
                }
                else {
                    $snake->dead(1);
                    $alive--;
                    next;
                }
            }

            my $col = $self->collision( $snake, @move );
            if ( $col == 0 ) {
                $snake->dead(1);
                $alive--;
                $human = 0 if !ref $cb && $cb eq 'human';
                next;
            }
            if ( $col == -1 ) {
                $loop = 0;
                $snake->grow(10);
                $self->put_apple;
                $win->attron( COLOR_PAIR( $snake->{color} ) );
                $win->addstr(
                    0,
                    $i * 8 + 1,
                    sprintf( "[%05s]", @{ $snake->snake } * 10 )
                );
            }

            $snake->go( $win, @move );
            $snake->direction(@move);
        }
    }
    $self->gameover;
    return map { scalar @{ $_->{snake} } } @{ $self->{snakes} };
}

sub end {
    my $self = shift;
    my $win  = $self->{win};
    endwin();
}

1;
