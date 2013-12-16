#!perl -alp
$|=($y,$x)=@F[4,5];@o=(-1,0,1,0);for$i(0..3){@p=@o[$i,3-$i];$_=$F[$i]eq'#'?next:"@p";last if($y&&abs($y+$p[0])>abs$y)+($x&&abs($x+$p[1])>abs$x)}