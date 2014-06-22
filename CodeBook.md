Input dataset url: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

R packages installed: data.table, plyr

Steps to transform input dataset to final output file "tidy_dataset_of_averages.txt":

1. read input files X_train.txt and X_test.txt and combine into a single data.table 'xcombined'
2. read input file features.txt and extract second column and transpose it to yield headers for 
   'xcombined' data.table in step 1 above. This vector is called 'allColumns'
3  identify subset of 'allColumns' that include columns which have 'mean' or 'std' in their name 
   but excludes columns that have 'meanFreq' in their name. This vector is called 'meanORstdColumns'
4. compute a projection of the data.table 'xcombined' by extracting columns whose names are in 
   'meanORstdColumns' and call this new data.table 'xcombinedProj'
5. clean up column names of 'xcombinedProj' by stripping out '()' and replacing '-' with '_'. 
   This is done for better readability
6. read input files y_train.txt, subject_train.txt, activity_labels.txt
7. read input files y_test.txt, subject_test.txt
8. combine train and test files for 'y' dimension into a single data.frame 'ycombined'
9. combine train and test files for 'subject' dimension into a single data.frame 
   'subjectcombined'
10. assign column name "activityid" to 'ycombined'
11. also add an "ordering" column to 'ycombined' which can be used to preserve order after the 
    merge with activitylabels (see 15 below)
12. add a new column called "subjectid" to 'ycombined' by assigning the first column of 
    'subjectcombined'
13. assign "activityid" and "activityname" as the two column names for the activitylabels data.frame read 
    in step 6 above from file activity_labels.txt
14. merge 'ycombined' and 'activitylabels' data.frames using common column name "activityid". 
    The resulting data.frame is called 'mergedycombined'
15. reorder 'mergedycombined' by sorting on column "ordering" which was created in step 11 for 
    this purpose
16. create 2 new columns "subjectid" and "activityname" in 'xcombinedProj' by assigning from the  
    corresponding columns in 'mergedycombined'
17. reorder the columns of 'xcombinedProj' so "subjectid" and "activityname" appear as the first 
    2 columns. This is done for better readability
18. finally sort 'xcombinedProj' by "subjectid" and "activityname"
19. write out the data table 'xcombinedProj' as intermediate output file "xcombinedProj.txt"
20. create the tidy data set by first composing the ddply expression and then evaluating it:
	a) create the arguments to ddply, one for each column that will appear in the final data 
	   frame. Each argument is of the form 'colname = mean(colname)'
	b) compose the ddply 'expressionString' including all col arguments computed in a) above
	c) parse and evaluate the 'expressionString'. The resulting data frame is called 
	   'tidy_dataset_of_averages'
	d) round all values in 'tidy_dataset_of_averages' to 3 decimal places for better 
	   readability
	e) write out 'tidy_dataset_of_averages' as file "tidy_dataset_of_averages.txt"
