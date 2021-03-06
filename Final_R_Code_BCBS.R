### Setting the working directory
getwd()
setwd("C:/UIC/Spring 16/Analytics Strategy/Project")

#### Reading the data file
x <- read.csv("UIC_Score Bin & Adverse Event Rate_UIC_adj.csv")
colnames(x)

#### using only relevant columns
mydata <- cbind(x[,1:4],  x[, 6:10],x[,12],x[,14],x[,16],x[,18:24], x[, 26])
colnames(mydata)
colnames(mydata)[10]<-"revision_knee_adj"
colnames(mydata)[11]<-"revision_hip_adj"
colnames(mydata)[12]<-"post_er_count_adj"
colnames(mydata)[20]<-"year_in_practice"
colnames(mydata)

#### checking data types of the class
sapply(mydata, class)

### Converting data types as per the requirement
mydata$Network <- as.factor(mydata$Network)
mydata$tjr_epi_cnt_adj <- as.numeric(mydata$tjr_epi_cnt_adj)
mydata$Cost <- as.numeric(mydata$Cost)

### Converting the Cost values into log for ease of calculation
mydata$Log_Cost <- log(mydata$Cost)
colnames(mydata)

#### Split the data in training and testing
library(ModelMap)
get.test(proportion.test = 0.3, qdatafn = mydata, seed = NULL, folder=getwd(),
         qdata.trainfn = "train.csv", qdata.testfn = "test.csv")

train <- read.csv("train.csv")
train <- data.frame(train)

test <- read.csv("test.csv")
test <- data.frame(test)

library(e1071)
library(mlbench)
library(MASS)

### Apply the model on training dataset
### SVM and linear regression , where Log_Cost is dependant variable
lm_train <- lm(Log_Cost ~ totl_epi_cnt + tjr_epi_cnt_adj   +
                 +                     post_wound_Infctn_fg +
                 +                    +                  post_bactrl_Infctn_fg + post_pneumonia_fg + post_UTI_fg +
                 +                    +                post_Clostrdm_Diffcl_fg + post_Jnt_Dislctn_fg, data = train)

svmFit_train <- svm(Log_Cost ~ totl_epi_cnt + tjr_epi_cnt_adj   +
                 +                     post_wound_Infctn_fg +
                 +                    +                  post_bactrl_Infctn_fg + post_pneumonia_fg + post_UTI_fg +
                 +                    +                post_Clostrdm_Diffcl_fg + post_Jnt_Dislctn_fg, data = train)


"
poly_d2 <- lm(Log_Cost ~ poly(Network, surgery_type, totl_epi_cnt, tjr_epi_cnt_adj, epi_disease_stg_num,
                          concurrent_risk, prospective_risk, revision_knee_adj, revision_hip_adj,
                          post_er_count_adj, post_adm_count_adj, post_wound_Infctn_fg, post_bactrl_Infctn_fg, 
                          post_bactrl_Infctn_fg, post_pneumonia_fg, post_UTI_fg, post_Clostrdm_Diffcl_fg,
                          post_Jnt_Dislctn_fg, degree = 2), data = train)
"
#### Error rate of the model
summary(lm_train)
AIC(lm_train)

summary(svmFit_train)
AIC(svmFit_train)

#### applyting the model on test dataset and predict Cost values
predictedY_test <- predict(lm_train, test)
summary(predictedY_test)

predictedY_test <- predict(svmFit_train, test)
summary(predictedY_test)

### Error calucalation
trn_RMSE <- sqrt(sum((lm_train$fit-train$Log_Cost)^2))
trn_RMSE
Tst_RMSE <- sqrt(sum((test$Log_Cost-predictedY_test)^2))
Tst_RMSE

trn_RMSE <- sqrt(sum((svmFit_train$fit-train$Log_Cost)^2))
trn_RMSE
Tst_RMSE <- sqrt(sum((test$Log_Cost-predictedY_test)^2))
Tst_RMSE