**Introduction**

Please have a look at [QDNAseqFlow-Abstract.pdf](https://github.com/NKI-Pathology/QDNAseqFlow/blob/master/QDNAseqFlow-Abstract.pdf) and [QDNAseqFlow\_poster\_ISMB.pdf](https://github.com/NKI-Pathology/QDNAseqFlow/blob/master/QDNAseqFlow_poster_ISMB.pdf) for an introduction.
To better understand how QDNAseq, the main component of this pipeline, works: [Christian-Rausch-QDNAseq-talk\_BioconductorDec2015.pdf](https://github.com/NKI-Pathology/QDNAseqFlow/blob/master/Christian-Rausch-QDNAseq-talk_BioconductorDec2015.pdf)

** Installation **

Go to https://github.com/NKI-Pathology/QDNAseqFlow and click button "Clone or Download" --> Download zip.
Unzip the zip file in your Home directory, 'My Documents' or where you are allowed to install programs.

**Required R-version etc.**

R: We have made most tests with R 3.4.1. QDNAseqFlow might work with older R versions but the risk is that some required libraries might not be available.
Java: You need to hava java installed. Make sure it is in your path. On Windows, this is done like here: https://confluence.atlassian.com/doc/setting-the-java_home-variable-in-windows-8895.html

**Usage**

This workflow consists of 3 main R-programs, that need to be run consecutively:

1. QDNAseq\_BAM2CopyNumbers.R
2. QDNAseq\_CopyNumbers2PlotsCallsSegmentFileInclDewave.R
3. QDNAseq\_FrequencyCGHregionsCGHtest.R

All of them can be run interactively, which means that simple GUIs pop-up at runtime that allow the user to select input files and parameters. The first two scripts can also be run with no GUI with command line options.

There are basically 3 equivalent ways to run the scripts:

1. From Rstudio: open script file and execute with CTRL-ALT-R
2. From the command line window:
/path/to/your/r-installation/Rscript QDNAseq\_BAM2CopyNumbers.R --interactive
or with no options or with --help to get an overview of available command line options.

    Likewise for the second script:
    /path/to/your/r-installation/Rscript QDNAseq\_BAM2CopyNumbers.R --interactive

    For the third script only:
    /path/to/your/r-installation/Rscript QDNAseq\_FrequencyCGHregionsCGHtest.R

    Note: Type 'Rscript.exe' on Windows.

3. Via a Batch file (.bat, on Windows only)
Edit the bat file with a text editor to adjust the path to your R-installation. Please note that the path must not contain white spaces, which means that R can not be installed at the default location on "program files", because otherwise no packages can be installed or compiled. This is ridiculous, please ask the R-developers.

**Dewaving  step (optional in script 3)**
The dewaving step is optional. Although it relies on published code (NoWave program), right now we only have one proprietary reference dataset available that is based on NGS data. We would need normal samples, ideally for every tumor type and are currently looking for such data (if you can help us, please let us know). For now, running the dewave step requires a key, due to the proprietary reference data.

**Odd things, to be improved**

Run and quit: Right now, when run from command line or from the bat file, the program just runs till the end closes the command window. Don&#39;t be surprised. I will make the programs more communicative.

Logging: For reproducibility and quality control, extensive logging of versions of used packages and progress is envisioned.
