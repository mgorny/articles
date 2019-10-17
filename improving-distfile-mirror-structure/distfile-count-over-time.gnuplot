set title "Gentoo distfile count and size over time"
set xlabel "Date"
set ylabel "Distfiles"
set y2label "Total distfile size [GiB]"
set xdata time
set timefmt "%Y-%m"
set xtics rotate by -45 format "%Y" timedate
set y2tics autofreq
set key autotitle columnheader left top
set terminal svg size 1000,600 dynamic
plot "distfile-count-over-time.txt" using 1:2 w lines, \
	"" using 1:3 w lines, \
	"" using 1:($5/1024/1024/1024) w lines axes x1y2, \
	"" using 1:($6/1024/1024/1024) w lines axes x1y2
