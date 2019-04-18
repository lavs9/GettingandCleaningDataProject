## ------------------------------------------------------------------------
library(dplyr)
library(data.table)


## ------------------------------------------------------------------------
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")


## ------------------------------------------------------------------------
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_data <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_data, recursive=TRUE)



## ------------------------------------------------------------------------
dataActivityTest  <- read.table(file.path(path_data, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_data, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_data, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_data, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_data, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_data, "train", "X_train.txt"),header = FALSE)


## ------------------------------------------------------------------------
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)


## ------------------------------------------------------------------------
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_data, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
df1 <- cbind(dataSubject, dataActivity)
df <- cbind(dataFeatures, df1)


## ------------------------------------------------------------------------
sub_dev_mean <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(sub_dev_mean), "subject", "activity" )

df<-subset(df,select=selectedNames)



## ------------------------------------------------------------------------
activityLabels <- read.table(file.path(path_data, "activity_labels.txt"),header = FALSE)

names(df)<-gsub("^t", "time", names(df))
names(df)<-gsub("^f", "frequency", names(df))
names(df)<-gsub("Acc", "Accelerometer", names(df))
names(df)<-gsub("Gyro", "Gyroscope", names(df))
names(df)<-gsub("Mag", "Magnitude", names(df))
names(df)<-gsub("BodyBody", "Body", names(df))



## ------------------------------------------------------------------------
Data<-aggregate(. ~subject + activity, df, mean)
Data<-Data[order(Data$subject,Data$activity),]
write.table(Data, file = "tidydata.txt",row.name=FALSE)

