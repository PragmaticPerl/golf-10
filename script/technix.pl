#!perl -alp
for$i(0..3){$|=@p=($i<3?$i-1:0,$i?2-$i:0);$_=$F[$i]eq'#'?next:"@p";last if grep$_*pop@p>0,@F[5,4]}