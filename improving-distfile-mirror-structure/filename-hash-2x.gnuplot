set title "File distribution using 8 msb of filename hash"
set xlabel "Hash prefix"
set ylabel "Distfiles"
set key autotitle columnheader
set xtics 0,16,255 format "%02x"
set terminal svg size 1000,600 dynamic
plot [-1:256] "filename-hash-2x.txt" using 2
