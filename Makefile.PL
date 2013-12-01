use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME           => 'golf-10',
    AUTHOR         => q{Vladimir Lettiev <crux@cpan.org>},
    VERSION        => '0.01',
    ABSTRACT       => 'Golf 10',
    BUILD_REQUIRES => { 'Curses' => 0 },
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    EXE_FILES => [<script/*.pl>, <*.pl>],
    PREREQ_PM => { 'Test::More' => 0, },
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'golf-10-*' },
);
