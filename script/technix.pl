#!perl -anlp
$|=($y,$x)=@F[4,5];@o=(-1,0,1,0);for$i(0..3){$_=$F[$i]eq'#'?next:"$o[$i] $o[3-$i]";last if($y&&abs($y+$o[$i])>abs$y)+($x&&abs($x+$o[3-$i])>abs$x)}