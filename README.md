GettingAndCleaningData: R script and related files for course project
======================================================================

run_analysis.R is the R script file that downloads the Dataset, reads in the various input files and creates two output files:
1. An intermediate output file called "xcombinedProj.txt" containing the 66 'mean' and 'std' columns of the input data as well as 2 additional columns to identify the 'subjectid' and 'activityname' for each row of data
2. A final output file called "tidy_dataset_of_averages" which  computes the mean for each column by subjectid and activityname.


