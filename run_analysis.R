#Script for getting and cleaning wearable technology data from SmartLabs Smartphone dataset

library(plyr)

#Load test data and training data
testdata <- read.table('UCI HAR Dataset/test/X_test.txt', header=FALSE)
traindata <- read.table('UCI HAR Dataset/train/X_train.txt', header=FALSE)

#Variable names for both datasets are given in column 2 of features.txt
features <- read.table('UCI HAR Dataset/features.txt')

colnames(testdata) <- features$V2
colnames(traindata) <- features$V2


#Activity labels for each dataset are given in y_test.txt and y_train.txt files
testlabels <- read.table('UCI HAR Dataset/test/y_test.txt')
trainlabels <- read.table('UCI HAR Dataset/train/y_train.txt')

testdata['ActivityLabel'] <- testlabels
traindata['ActivityLabel'] <- trainlabels


#The ID numbers of the subjects who performed each activity are given in subject_test.txt
#and subject_train.txt files
testsubjects <- read.table('UCI HAR Dataset/test/subject_test.txt')
trainsubjects <- read.table('UCI HAR Dataset/train/subject_train.txt')

testdata['Subject'] <- testsubjects
traindata['Subject'] <- trainsubjects


#Combine both test and training datasets into one
fulldata <- rbind(testdata, traindata)


#We want to extract out only the columns that represent the mean or standard deviation of each measurement
#Find the appropriate variables by searching the variable names for 'mean()' or 'std()', and extract them 
#to a new data frame. (We need to also keep ActivityLabel and Subject - cols 562 and 563)

VarsToKeep <- grep('mean\\(\\)|std\\(\\)', colnames(fulldata))
AverageData <- fulldata[, c(562, 563, VarsToKeep)]


#Descriptive activity labels are found in column 2 of 'activity_labels.txt' file. Replace activity label
#numbers in the dataset with the descriptive label

DescriptiveLabels <- read.table('UCI HAR Dataset/activity_labels.txt')
AverageData$ActivityLabel <- DescriptiveLabels$V2[AverageData$ActivityLabel]


#Reformat variable names to make them more descriptive:
#'t' at the start of a variable name represents time, and 'f' represents frequency
VarNames <- colnames(AverageData)
VarNames <- gsub('^t', 'Time_', VarNames)
VarNames <- gsub('^f', 'Freq_', VarNames)
#Remove brackets
VarNames <- gsub('\\(|\\)', '', VarNames)

#Acc means an acceleration measurement, Gyro means angular momentum, and Mag means Magnitude
VarNames <- gsub('Acc', 'Acceleration', VarNames)
VarNames <- gsub('Gyro', 'AngularMomentum', VarNames)
VarNames <- gsub('Mag', 'Magnitude', VarNames)

#Tidy variable names with 'BodyBody' in them
VarNames <- gsub('BodyBody', 'Body', VarNames)

colnames(AverageData) <- VarNames


#Make a new data frame that summarises the mean of each measurement per activity per subject

SummaryData <- ddply(AverageData, c('ActivityLabel', 'Subject'), numcolwise(mean))

write.table(SummaryData, 'UCI_HAR_DATA_cleaned.txt', row.names = FALSE)
