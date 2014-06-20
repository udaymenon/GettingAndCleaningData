## Getting and Cleaning Data Course Project

##You should create one R script called run_analysis.R that does the following.
##Merges the training and the test sets to create one data set.
##Extracts only the measurements on the mean and standard deviation for each measurement.
##Uses descriptive activity names to name the activities in the data set
##Appropriately labels the data set with descriptive variable names.
##Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

setwd("C:/Users/Room2/Documents/datascience coursework/GettingAndCleaningData/Dataset/UCI HAR Dataset")
##download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "Dataset.zip")

#install.packages("data.table", "plyr")
library(data.table)
library(plyr)

## read in files X_train.txt and X_test.txt
xtrain <- read.table("train/X_train.txt", header=FALSE)
xtest <- read.table("test/X_test.txt", header=FALSE)

##combine the two datasets and convert to data.table
xcombined <- rbind(xtrain,xtest)
xcombined <- as.data.table(xcombined)

##read file features.txt
features <- read.table("features.txt", header=FALSE, stringsAsFactors=FALSE)

##extract transpose of second column and assign as colnames for xtrain
headers <- t(features$V2)
setnames(xcombined,names(xcombined),headers)

##project columns that are mean or std of the measurements
allColumns <- names(xcombined)
meanORstdColumns <- grep("std|mean", allColumns, value=TRUE)
meanORstdColumns <- grep("meanFreq", meanORstdColumns, ignore.case = TRUE, invert=TRUE, value=TRUE)

##Note: since this is a data.table, need the 'with=FALSE' to make this work!
xcombinedProj <- xcombined[,meanORstdColumns,with=FALSE]

##Clean up column names by stripping out '()' and replacing '-' with '_'
##This obviates the need for quotes around the names
meanORstdColumns <- gsub("[()]","",meanORstdColumns)
meanORstdColumns <- gsub("-","_",meanORstdColumns)

setnames(xcombinedProj,names(xcombinedProj),meanORstdColumns)

## read in files y_train.txt, subject_train.txt, activity_labels.txt
ytrain <- read.table("train/y_train.txt", header=FALSE)
subjecttrain <- read.table("train/subject_train.txt", header=FALSE)
activitylabels <- read.table("activity_labels.txt", header=FALSE)

## read in files y_test.txt, subject_test.txt, activity_labels.txt
ytest <- read.table("test/y_test.txt", header=FALSE)
subjecttest <- read.table("test/subject_test.txt", header=FALSE)

##combine the two datasets on y and subject data
ycombined <- rbind(ytrain,ytest)
subjectcombined <- rbind(subjecttrain,subjecttest)

##Assign column names to support merge of the two data frames.
##Also add an "ordering" column to ycombined which can be used
##to preserve order after the merge with activitylabels

names(ycombined) <- c("activityid")
ycombined$ordering <- seq(from=1,to= nrow(ycombined),by = 1)
ycombined$subjectid <- subjectcombined$"V1"
names(activitylabels) <- c("activityid", "activityname")
mergedycombined <- merge(ycombined,activitylabels)
mergedycombined <- mergedycombined[order(mergedycombined$ordering),]

## Now add the subjectid & activityname columns to xcombinedProj
xcombinedProj$activityname <- mergedycombined$activityname
xcombinedProj$subjectid <- mergedycombined$subjectid

##Reorder the columns so subjectid and activityname appear as the first 2 columns
newcolorder <- c("subjectid","activityname",meanORstdColumns)
setcolorder(xcombinedProj,newcolorder)

## Finally sort by subjectid and activityname
xcombinedProj <- xcombinedProj[order(xcombinedProj$subjectid,xcombinedProj$activityname),]

write.table(xcombinedProj,"xcombinedProj.txt")

## create tidy dataset that includes averages for these activities grouped by subjectid and activity
## This is done by first composing the ddply expression and then evaluating it

## Create the arguments to ddply, one for each column that will appear in the final data frame
## each argument is of the form 'colname = mean(colname)'

argString <- ""
firstTwoCols <- c("subjectid","activityname")
for (colname in names(xcombinedProj)) {
  if (!(colname %in% firstTwoCols))
    argString <- paste(argString,",", colname,"=mean(",colname,")", sep="")
}

##compose the ddply expression including all col arguments computed
expressionString <- paste("ddply(xcombinedProj, .(subjectid, activityname), summarize", argString,")", sep="")

##Compute second independent tidy dataset by evaluating ddply expression
tidy_dataset_of_averages <- eval(parse(text = expressionString))

##Round all values to 3 decimal places
tidy_dataset_of_averages[,c(-1,-2)] <- round(tidy_dataset_of_averages[,c(-1,-2)],3)

##Write out final dataset
write.table(tidy_dataset_of_averages,"tidy_dataset_of_averages")

