#!/usr/bin/perl -an

# autoflush
$| = 1;

my ( $top, $right, $bottom, $left, $dy, $dx ) = @F;

my ( $x, $y ) = ( 0, 0 );

if ( $dy > 0 && $bottom ne '#' ) {
    $y = 1;
}
elsif ( $dy < 0 && $top ne '#' ) {
    $y = -1;
}
elsif ( $dx > 0 && $right ne '#' ) {
    $x = 1;
}
elsif ( $dx < 0 && $left ne '#' ) {
    $x = -1;
}

if ( $y == 0 && $x == 0 ) {
    if ( $bottom ne '#' ) {
        $y = 1;
    }
    elsif ( $top ne '#' ) {
        $y = -1;
    }
    elsif ( $right ne '#' ) {
        $x = 1;
    }
    else {
        $x = -1;
    }
}
print "$y $x\n";

