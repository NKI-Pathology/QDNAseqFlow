# this script is not required for QDNAseqFlow
# it is for testing only.
# Purpose: test if the path to the location of the file "QDNAseq-observedVariance.R" can be correctly determined

# FUNCTIONS ============================================================================================
# Function sampleNames: return the sample names from a QDNAseq object
sampleNames <- function(largeQDNAseqCopyNumbers){
  sampleNames <- {largeQDNAseqCopyNumbers@phenoData}@data$name
  return(sampleNames)
}

# Function pathToScriptWithScriptname
pathToScriptWithScriptname <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  needle <- "--file="
  match <- grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript
    return(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    # 'source'd via R console
    return(normalizePath(sys.frames()[[1]]$ofile))
  }
}

# create stop function which exits with a blank message (still, an error is generated!)
# TODO: use another way to terminate the program without generating an error
# source: https://stackoverflow.com/questions/14469522/stop-an-r-program-without-error
stopQuietly <- function(...) {
  blankMsg <- sprintf("\r%s\r", paste(rep(" ", getOption("width")-1L), collapse=" "));
  stop(simpleError(blankMsg));
} # stopQuietly()


# End of FUNCTIONS =====================================================================================




#options(echo=TRUE) # if you want to see commands in output file
args <- commandArgs(trailingOnly = TRUE)

#print("Command line arguments set: ", args)
cat("Command line arguments set: ")
print(args)

isRStudio <- Sys.getenv("RSTUDIO") == "1" # running this script from within RStudio is equivalent to using option --interactive
if(isRStudio) {args[1] <- "--interactive"}
print(isRStudio)




# get the path where this script is in:
currentpathToScriptWithScriptname = pathToScriptWithScriptname()
library(stringr)
#currentpathToScript = str_extract(string = currentpathToScriptWithScriptname , "/.*/")
currentpathToScript = str_extract(string = currentpathToScriptWithScriptname , "/.*/|.*\\\\") # /Unix/ OR C:\Windows\ style of path
print(currentpathToScript)
print(paste0(currentpathToScript, "/QDNAseq-observedVariance.R"))

