set title "File distribution using 4 msb of file hash"
set xlabel "Hash prefix"
set ylabel "Distfiles"
set key autotitle columnheader
set terminal svg size 1000,600 dynamic
plot [-1:16] "file-hash-1x.txt" using 2:xticlabels(1)
