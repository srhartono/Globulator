# draw.R by Stella
# Create pdf image based on imageJ result GLOB_.txt
#
######################

library(plotrix)

ARGV = commandArgs(trailingOnly = TRUE)
print(ARGV)
input  = ARGV[1]
output = ARGV[2]
glob = read.table(input, sep="\t",skip=2,header=T)
pdf(output)
xlim = round(max(glob[,2])*1.1+1)
ylim = round(max(glob[,3])*1.1+1)
pi = 3.14159265359

plot(NA,xlim=c(0,xlim),ylim=c(-1 * ylim,0),xlab=NA, ylab=NA)
title(main = "Globules Map")

for (i in 1:dim(glob)[1]) {
        rad = sqrt(glob[i,1]/pi)
        x = glob[i,2]
        y = glob[i,3]
        draw.circle(x,-1 * y,rad,col=NA,border="blue")
}

