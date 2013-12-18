#!perl -alp
$|=@o=(-1,0,1,0);for$i(0..3){@p=@o[$i,3-$i];$_=$F[$i]eq'#'?next:"@p";$c=$d=0;map{$c+=$_&&abs($_+$p[$d])>abs;$d++}@F[4,5];last if$c}