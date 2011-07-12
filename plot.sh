set term png truecolor size 1000, 800
set output "plot.png"
set logscale x
plot "summary.txt" with lines