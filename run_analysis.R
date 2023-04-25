
## Get and load data for this project
zipURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFILE = "UCI HAR Dataset.zip"

if (!file.exists(zipFILE)) {
  download.file(zipURL, zipFILE, mode = "wb")
}

dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
  unzip(zipFILE)
}

## Use dplyr package
library(dplyr)

## Read in data
train.subjects <- read.table(file.path(dataPath, "train", "subject_train.txt"))
train.values <- read.table(file.path(dataPath, "train", "X_train.txt"))
train.activity <- read.table(file.path(dataPath, "train", "y_train.txt"))

test.subjects <- read.table(file.path(dataPath, "test", "subject_test.txt"))
test.values <- read.table(file.path(dataPath, "test", "X_test.txt"))
test.activity <- read.table(file.path(dataPath, "test", "y_test.txt"))

features <- read.table(file.path(dataPath, "features.txt"), as.is = TRUE)

activities <- read.table(file.path(dataPath, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")

## Merge datasets 
human.activity <- rbind(
  cbind(train.subjects, train.values, train.activity),
  cbind(test.subjects, test.values, test.activity)
)

colnames(human.activity) <- c("subject", features[, 2], "activity")


## Extract only mean and standard deviation for each measurement
columnsToKeep <- grepl("subject|activity|mean|std", colnames(human.activity))
human.activity <- human.activity[, columnsToKeep]

## Label activity names in data set
human.activity$activity <- factor(human.activity$activity, 
                                 levels = activities[, 1], labels = activities[, 2])

human.activityCols <- colnames(human.activity)

human.activityCols <- gsub("[\\(\\)-]", "", human.activityCols)

human.activityCols <- gsub("^f", "frequencyDomain", human.activityCols)
human.activityCols <- gsub("^t", "timeDomain", human.activityCols)
human.activityCols <- gsub("Acc", "Accelerometer", human.activityCols)
human.activityCols <- gsub("Gyro", "Gyroscope", human.activityCols)
human.activityCols <- gsub("Mag", "Magnitude", human.activityCols)
human.activityCols <- gsub("Freq", "Frequency", human.activityCols)
human.activityCols <- gsub("mean", "Mean", human.activityCols)
human.activityCols <- gsub("std", "StandardDeviation", human.activityCols)

human.activityCols <- gsub("BodyBody", "Body", human.activityCols)

colnames(human.activity) <- human.activityCols


## Create tidy dataset
humanActivityMeans <- human.activity %>% 
  group_by(subject, activity) %>%
  summarise_each(funs(mean))

write.table(humanActivityMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)
