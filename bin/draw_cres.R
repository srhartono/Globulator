# draw.R by Stella
# Create pdf image based on imageJ result CRES_.txt 
#
######################

library(plotrix)

ARGV = commandArgs(trailingOnly = TRUE)
print(ARGV)
input  = ARGV[1]
output = ARGV[2]
cres = read.table(input, sep="\t",skip=2,header=T)
pdf(output)
xlim = round(max(cres[,2])*1.1+1)
ylim = round(max(cres[,3])*1.1+1)
pi = 3.14159265359

plot(NA,xlim=c(0,xlim),ylim=c(-1 * ylim,0), xlab=NA, ylab=NA)
title(main="Crescent Map")

for (i in 1:dim(cres)[1]) {
        rad = sqrt(cres[i,1]/pi)
        x = cres[i,2]
        y = cres[i,3]
        draw.circle(x,-1 * y,rad,col=NA,border="red")
}
