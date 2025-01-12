# Load Packages and Directly Download Files
library('data.table')
library('reshape2')

path <- getwd()
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, 'project3.zip'))
unzip(zipfile = 'project3.zip')

# Load Activity Labels & Name respectively
activityL <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                   ,col.names = c('classLabels', 'activityName'))

# Load Features Labels & Names respectively
feat <- fread(file.path(path, "UCI HAR Dataset/features.txt")
              ,col.names = c('index','featureNames'))

# Obtain Wanted Features and Measurements
featWanted <- grep("(mean|std)\\(\\)", feat[, featureNames])
meas <- feat[featWanted, featureNames]
meas <- gsub('[()]', '', meas)

# Load train datasets
train <- fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"))[, featWanted, with = FALSE]
setnames(train, colnames(train), meas)
trainAct <- fread(file.path(path, 'UCI HAR Dataset/train/y_train.txt'), col.names = c('Activity'))
trainSub <- fread(file.path(path, 'UCI HAR Dataset/train/subject_train.txt'), col.names = c('SubjectNum'))
train <- cbind(trainSub, trainAct, train)

# Load test datasets
test <- fread(file.path(path, 'UCI HAR Dataset/test/X_test.txt'))[, featWanted, with = FALSE]
setnames(test, colnames(test), meas)
testAct <- fread(file.path(path, 'UCI HAR Dataset/test/y_test.txt'), col.names = c('Activity'))
testSub <- fread(file.path(path, 'UCI HAR Dataset/test/subject_test.txt'), col.names = c('SubjectNum'))
test <- cbind(testSub, testAct, test)

# Merge Both Test & Train dataset
combi <- rbind(train, test)

# Convert classLabels to activityName
combi[['Activity']] <- factor(combi[, Activity]
                              ,levels = activityL[['classLabels']] 
                              ,labels = activityL[['activityName']])

combi[['SubjectNum']] <-as.factor(combi[, SubjectNum])
combi <- reshape2::melt(data = combi, id = c('SubjectNum','Activity'))
combi <- reshape2::dcast(data = combi, SubjectNum + Activity ~ variable, fun.aggregate = mean)


# Export the Text File for Data
fwrite(x = combi, file = "tidyData.txt", quote = FALSE)