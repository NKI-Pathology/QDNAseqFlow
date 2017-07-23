# FUNCTIONS ============================================================================================

# Function to create a frequency plot
frequencyPlotPerInputClass <- function(qdnaseqObject_copyNumbers, sampleSelection, selectedClass, filenameOfFrequencyplot) {
  mysamples <- qdnaseqObject_copyNumbers@phenoData@data$name
  mymatches <- grepl(paste(sampleSelection$V1[sampleSelection$V2==selectedClass],collapse="|"), mysamples)
 # browser()
  png(file=filenameOfFrequencyplot, width = 1280, height = 1024)
  frequencyPlot(qdnaseqObject_copyNumbers[,mymatches])
  # for testing: frequencyPlot(qdnaseqObject_copyNumbers)
  dev.off()
  filenameOfFrequencyplotTXT = sub("png", "txt", filenameOfFrequencyplot, perl=TRUE)
  write.table(samples[mymatches], filenameOfFrequencyplotTXT, quote=F, sep="\t", col.names = FALSE, row.names = FALSE)
}

# LOAD packages and libraries  =========================================================================

# ... from CRAN
list.of.packages <- c("R.cache", "tcltk", "gWidgetstcltk", "gWidgets", "devtools")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='https://cran.uni-muenster.de/')

# ... from Bioconductor
list.of.bioconductor.packages <- c("QDNAseq", "QDNAseq.hg19", "CGHregions")
new.bioconductor.packages <- list.of.bioconductor.packages[!(list.of.bioconductor.packages %in% installed.packages()[,"Package"])]
if(length(new.bioconductor.packages)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite(new.bioconductor.packages)[,"Package"]
}

# ... from remote file to be downloaded from URL (here: Mark vd Wiels web site: http://www.few.vu.nl/~mavdwiel/CGHtest.html)
if(!"CGHtest" %in% installed.packages()) {
  install.packages('http://www.few.vu.nl/%7Emavdwiel/CGHtest/CGHtest_1.1.tar.gz',repos = NULL)
}
# ... from local file previously downloaded (from Mark vd Wiels web site)
#install.packages('CGHtest_1.1.tar.gz', lib='/home/christian/Rmylocallibs/',repos = NULL)
#library('CGHtest', lib='/home/christian/Rmylocallibs/')


library(CGHtest)
library(QDNAseq)
library(QDNAseq.hg19)
library(R.cache, quietly = TRUE)
library(tcltk)
library(gWidgets)
library(CGHregions)
# end of loading libraries

# import input files via GUI
filenameOfCopyNumbersCalledRDSfile <- tk_choose.files(caption = "Please select your copy numbers called file. E.g. copyNumbersCalled-30kb-bins.rds")
filenameOfSelection = tk_choose.files(caption = "Please select your selections-file. It MUST be a .csv, a comma separated values file")
copyNumbersCalled = readRDS(filenameOfCopyNumbersCalledRDSfile)
samples <- copyNumbersCalled@phenoData@data$name
sampleSelection <- read.csv(header = FALSE, file = filenameOfSelection)
selectionClasses = levels(sampleSelection$V2)


# do frequency plot for each of the classes
# run cghregions for each of pair of classes
# for each pair of classes run CGHtest for gains and losses


for (selectedClass in levels(sampleSelection$V2)) {
  # example: selectedClass = "small_bowel"
  filenameOfFrequencyplot = sub("csv",  paste(selectedClass, ".frequency-plot.png", sep=""), filenameOfSelection, perl=TRUE)
  frequencyPlotPerInputClass(copyNumbersCalled, sampleSelection, selectedClass, filenameOfFrequencyplot)
}

combis = combn(selectionClasses, 2)

for (i in (1:dim(combis)[2])) {
  print(combis[1:2,i])
  
  # don't do the following because the files of the two classes could be interleaved
  #matches <- grepl(paste(sampleSelection$V1[sampleSelection$V2==combis[1,i]|sampleSelection$V2==combis[2,i]],collapse="|"), samples)
  #cghcall <- makeCgh(copyNumbersCalled[,matches])
  #cghregions <- CGHregions(cghcall, averror=0.01)
 # browser()
  matches1 <- grepl(paste(sampleSelection$V1[sampleSelection$V2==combis[1,i]],collapse="|"), samples)
  matches2 <- grepl(paste(sampleSelection$V1[sampleSelection$V2==combis[2,i]],collapse="|"), samples)
  cghcall1 <- makeCgh(copyNumbersCalled[,matches1])
  cghcall2 <- makeCgh(copyNumbersCalled[,matches2])
  cghcallcombined <-  combine(cghcall1, cghcall2)
  numberOfSamples1 <- dim(cghcall1)[2]
  numberOfSamples2 <- dim(cghcall2)[2]
  cghregions <- CGHregions(cghcallcombined, averror=0.01)
  
  # for testing:
  #cghcall14 <- makeCgh(copyNumbersCalled[,1:4])
  #cghregions <- CGHregions(cghcall14, averror=0.01)
  datainfo <- data.frame(chromosomes(cghregions), bpstart(cghregions), bpend(cghregions), nclone(cghregions), avedist(cghregions))
  datacgh <- regions(cghregions)
  gfr <- groupfreq(datacgh,group=c(numberOfSamples1,numberOfSamples2),groupnames=c(combis[1,i],combis[2,i]),af=0.1)
  filename_prefix_CGHtestOutput = sub("csv",  paste(combis[1,i], "_vs_",combis[2,i], ".CGHtest", sep=""), filenameOfSelection, perl=TRUE)
  teststats = c("Wilcoxon", "Chi-square")
 # teststats = "Wilcoxon"
#j = 1
  for (j in c(-1, 1)) {
    if (j == -1) gainORloss = "loss"
    if (j == 1) gainORloss = "gain"
 
    for (k in (1:length(teststats))) {
      pvs <- pvalstest(datacgh,datainfo, teststats[k] ,group=c(numberOfSamples1,numberOfSamples2),groupnames=c(combis[1,i], combis[2,i]), af=0.1, niter=10000, lgonly = j)
      fdrs <- fdrperm(pvs,mtdirection="stepup")
      filename_CGHtestOutput = paste(filename_prefix_CGHtestOutput, "_", teststats[k], "_", gainORloss, ".tab", sep="")
      write.table(fdrs, file=filename_CGHtestOutput, sep="\t", row.names = FALSE)
    }
  }
  filenameOfCGHregionsOutput = sub("CGHtest", "CGHregions.tab", filename_prefix_CGHtestOutput, perl=TRUE)
  df <- data.frame( chromosomes(cghregions), bpstart(cghregions), bpend(cghregions), nclone(cghregions), avedist(cghregions), regions(cghregions) )
  write.table(df, filenameOfCGHregionsOutput, quote=F, sep="\t")
  
}
