R Notebook
================

Create one R script called run\_analysis.R that does the following: 1.
Merges the training and the test sets to create one data set. 2.
Extracts only the measurements on the mean and standard deviation for
each measurement. 3. Uses descriptive activity names to name the
activities in the data set 4. Appropriately labels the data set with
descriptive activity names. 5. Creates a second, independent tidy data
set with the average of each variable for each activity and each
subject.

Importing Libraries

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(data.table)
```

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

Download the file and put the file in the data folder

``` r
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
```

Unzip the file

``` r
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_data <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_data, recursive=TRUE)
```

As per the README.txt file for the detailed information on the dataset.
For the purposes of this project, the files in the Inertial Signals
folders are not used. The files that will be used to load data are
listed as follows: test/subject\_test.txt test/X\_test.txt
test/y\_test.txt train/subject\_train.txt train/X\_train.txt
train/y\_train.txt

``` r
dataActivityTest  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_data, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)
```

Merging the Data sets

``` r
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
```

Set Names to vairables and merge to get data

``` r
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
df1 <- cbind(dataSubject, dataActivity)
df <- cbind(dataFeatures, df1)
```

Extracts only the measurements on the mean and standard deviation for
each
measurement.

``` r
sub_dev_mean <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(sub_dev_mean), "subject", "activity" )

df<-subset(df,select=selectedNames)
```

Uses descriptive activity names to name the activities in the data
set.Appropriately labels the data set with descriptive activity
names.

``` r
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"),header = FALSE)

names(df)<-gsub("^t", "time", names(df))
names(df)<-gsub("^f", "frequency", names(df))
names(df)<-gsub("Acc", "Accelerometer", names(df))
names(df)<-gsub("Gyro", "Gyroscope", names(df))
names(df)<-gsub("Mag", "Magnitude", names(df))
names(df)<-gsub("BodyBody", "Body", names(df))
```

Creates a second, independent tidy data set with the average of each
variable for each activity and each subject.

``` r
Data<-aggregate(. ~subject + activity, df, mean)
Data<-Data[order(Data$subject,Data$activity),]
write.table(Data, file = "tidydata.txt",row.name=FALSE)
```
