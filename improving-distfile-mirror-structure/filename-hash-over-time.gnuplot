set title "Analysis of group sizes in 8-bit filename hash split over time"
set xlabel "Date"
set ylabel "Distfiles per group"
set y2label "Relative standard deviation"
set xdata time
set timefmt "%Y-%m"
set xtics rotate by -45 format "%Y" timedate
set y2tics autofreq
set key autotitle columnheader
set terminal svg size 1000,600 dynamic
plot "filename-hash-over-time.txt" using 1:8 w lines, \
	"" using 1:10:11:12 w errorbars, \
	"" using 1:($9/$8) w lines axes x1y2
