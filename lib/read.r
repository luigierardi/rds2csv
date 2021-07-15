

library(jsonlite)

args <- commandArgs(TRUE)
srcFile <- args[1]

dat <- readRDS(srcFile)

cat (paste("File source ", srcFile, "\n", sep=""))

if ( is.data.frame(dat) ) {
	# OK
	adtm.m<-as.data.frame(dat)
        dstFile <- paste(substring(srcFile, 1, nchar(srcFile)-3),"csv", sep = "")
	write.csv(adtm.m, dstFile)
} else if ( is.matrix(dat) ) {
	adtm.m<-as.matrix(dat)
        dstFile <- paste(substring(srcFile, 1, nchar(srcFile)-3),"csv", sep = "")
	write.csv(adtm.m, dstFile)
} else if ( is.list(dat) ) {
	adtm.m<-as.matrix(dat)
	dstFile <- paste(substring(srcFile, 1, nchar(srcFile)-3),"csv", sep = "")
	write.csv(adtm.m, dstFile)
} else {
	# OK
	adtm.m<-as.matrix(dat)
        dstFile <- paste(substring(srcFile, 1, nchar(srcFile)-3),"json", sep = "")
	cat(adtm.m, file=dstFile,sep="\n")
}
