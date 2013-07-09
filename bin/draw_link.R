# draw.R by Stella
# Create pdf file of LINK_ globule and crescent linked file
#
######################

library(plotrix)

ARGV = commandArgs(trailingOnly = TRUE)
print(ARGV)
input  = ARGV[1]
output = ARGV[2]
data = read.table(input, sep="\t",skip=2,header=T)
cres = data[,1:3]
glob = data[,4:6]
pdf(output)
xlim_cres = round(max(cres[,2])*1.1+1)
xlim_glob = round(max(glob[,2])*1.1+1)
ylim_cres = round(max(cres[,3])*1.1+1)
ylim_glob = round(max(glob[,3])*1.1+1)

xlim = xlim_cres
if(xlim_cres < xlim_glob) {
        xlim = xlim_glob
}
ylim = ylim_cres
if(ylim_cres < ylim_glob) {
        ylim = ylim_glob
}

plot(NA,xlim=c(0,xlim),ylim=c(-1 * ylim,0), xlab=NA, ylab=NA)
title(main="Linked Globule and Crescent Map")

for (i in 1:dim(cres)[1]) {
        rad = sqrt(cres[i,1]/pi)
        x = cres[i,2]
        y = cres[i,3]
        draw.circle(x, -1 * y, rad,col=NA,border="red")
}

for (i in 1:dim(glob)[1]) {
        rad = sqrt(glob[i,1]/pi)
        x = glob[i,2]
        y = glob[i,3]
        draw.circle(x, -1 * y, rad,col=NA,border="blue")
}
