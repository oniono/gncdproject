# run_analysis.R does the following.
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, 
#    independent tidy data set with the average of each variable for each activity and each subject.

# Set workspace
setwd("C:\\DataScience\\3\\Project")

# Download data
library(httr) 
downloadUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
downloadFile <- "Data.zip"
if(!file.exists(downloadFile)){
  print("Download data...")
  download.file(downloadUrl, downloadFile, method="wininet")
}

# Unzip downloaded zip file and create folders (overwrite)
dataFolder <- "UCI HAR Dataset"
resultsFolder <- "Results"

if(!file.exists(dataFolder)){
  print("Unzip file...")
  unzip(downloadFile, list = FALSE, overwrite = TRUE)
}

if(!file.exists(resultsFolder)){
  print("Create results folder")
  dir.create(resultsFolder)
} 

# Read text file and covnert to data.frame
txtToDataframe <- function (filename, cols = NULL){
  print(paste("Read text file:", filename))
  
  path <- paste(dataFolder, filename, sep="/")
  
  if(is.null(cols)){
    data <- read.table(path, sep="", stringsAsFactors=F)
  } 
  else {
    data <- read.table(path, sep="", stringsAsFactors=F, col.names= cols)
  }
  
  data
}

# Read data and convert to dataframe
features <- txtToDataframe("features.txt")

# Read textfile and build database
getdata <- function(type, features){
  print(paste("Get data:", type))
  
  print(paste(type,"/", "subject_", type, ".txt", sep=""))
  subject_data <- txtToDataframe(paste(type,"/", "subject_", type, ".txt", sep=""), "id")
  
  print(paste(type,"/", "y_", type, ".txt", sep=""))
  y_data <- txtToDataframe(paste(type,"/", "y_", type, ".txt", sep=""), "activity")
  
  print(paste(type,"/", "X_", type, ".txt", sep=""))
  x_data <- txtToDataframe(paste(type,"/", "X_", type, ".txt", sep=""), features$V2)
  
  return (cbind(subject_data, y_data, x_data))
}

# Build test and train data
testData <- getdata("test", features)
trainData <- getdata("train", features)

# Save the results
saveResults <- function (data, fileName){
  print(paste("Save results", fileName))
  fileName <- paste(resultsFolder, "/", fileName,".txt" ,sep="")
  write.table(data, fileName, row.name=FALSE)
}

# Assignments

# 1. Merges the training and the test data
library(plyr)
data <- rbind(trainData, testData)
data <- arrange(data, id)

# 2. Extracts the mean and standard deviation
meanStd <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))]
saveResults(meanStd, "meanStd")

# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- txtToDataframe("activity_labels.txt")

# 4. Appropriately labels the data set with descriptive variable names. 
data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2)

# 5. From the data set in step 4, 
#    creates a second, independent tidy data set with the average of each variable 
#    for each activity and each subject.

tidyDataset <- ddply(meanStd, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })
colnames(tidyDataset)[-c(1:2)] <- paste(colnames(tidyDataset)[-c(1:2)], "_mean", sep="")
saveResults(tidyDataset, "tidyDataset")
