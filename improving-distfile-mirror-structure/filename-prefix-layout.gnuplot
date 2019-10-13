set title "File distribution using filename prefix"
set xlabel "Prefix"
set ylabel "Distfiles"
set key autotitle columnheader
set logscale y
set terminal svg size 1000,600 dynamic
plot [-1:27] "filename-prefix-layout.txt" using 2:xticlabels(1)
