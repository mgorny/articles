set title "Gentoo distfile count over time"
set xlabel "Date"
set ylabel "Distfiles"
set xdata time
set timefmt "%Y-%m"
set xtics rotate by -45 format "%Y" timedate
set key autotitle columnheader
set terminal svg size 1000,600 dynamic
plot "distfile-count-over-time.txt" using 1:2 w lines, \
	"" using 1:3 w lines
