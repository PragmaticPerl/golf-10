#!perl -alp
$|=@o=(-1,0,1,0);for$i(0..3){@p=@o[$i,3-$i];$_=$F[$i]eq'#'?next:"@p";last if map{abs($_+pop@p)>abs&&$_?1:()}@F[5,4]}