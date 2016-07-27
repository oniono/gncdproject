# gncdproject
Peer Graded Assignment: Getting and Cleaning Data Course Project


# How the script works 
1. Set workspace
2. Download data(zip file) from given url
3. Unzip downloaded zip file and create folders (overwrite)
4. Read text file and covnert to data.frame
5. Read data(feature.txt) and convert to dataframe
6. Read textfile and build database
7. Build test and train data

# Assignments

1. Merges the training and the test data

    library(plyr)
    data <- rbind(trainData, testData)
    data <- arrange(data, id)

2. Extracts the mean and standard deviation

    meanStd <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))]
    
    saveResults(meanStd, "meanStd")

3. Uses descriptive activity names to name the activities in the data set

    activity_labels <- txtToDataframe("activity_labels.txt")

4. Appropriately labels the data set with descriptive variable names. 

    data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2)

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

    tidyDataset <- ddply(meanStd, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })
    
    colnames(tidyDataset)[-c(1:2)] <- paste(colnames(tidyDataset)[-c(1:2)], "_mean", sep="")
    
    saveResults(tidyDataset, "tidyDataset")

