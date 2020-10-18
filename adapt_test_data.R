TESTING<-data.frame(read_csv("pml-testing.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
TESTING
str(TESTING)
########################################
TESTING_net_new<-data.frame(read_csv("WearableComputing_weight_lifting_exercises_biceps_curl_variations.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
str(TESTING_net_new)
# names(TESTING_net_new)
# names(TESTING)
names(TESTING_net_new)[15]<-"skewness_roll_belt.1"
names(TESTING_net_new)[which(!names(TESTING_net_new) %in% names(TESTING))]
names(original_training)[which(!names(original_training) %in% names(TESTING_net_new))]
TESTING_net_new<-setdiff(TESTING_net_new[,-15],original_training[,-c(1,16)])
nrow(inner_join(original_training, TESTING_net_new))
#head(TESTING_net_new[1:10,1:10])

TESTING<-filter(TESTING, new_window=="no")%>%select(-c(user_name, cvtd_timestamp, X1, raw_timestamp_part_1, raw_timestamp_part_2, num_window, new_window))
TESTING_net_new<-filter(TESTING_net_new, new_window=="no")%>%select(-c(user_name, cvtd_timestamp, raw_timestamp_part_1, raw_timestamp_part_2, num_window, new_window))

#clean_no<-which(names(training_new_window_no) %in% as.list(filter(varmap, is.na(junk_status)==T & is.na(nzv_no)==T & is.na(high_corr_no)==T))$varname)
clean_no_TESTING<-which(names(TESTING) %in% as.list(filter(varmap, is.na(nzv_no)==T & is.na(high_corr_no)==T))$varname)
clean_no_TESTING_net_new<-which(names(TESTING_net_new) %in% as.list(filter(varmap, is.na(nzv_no)==T & is.na(high_corr_no)==T))$varname)

TESTING_net_new<-TESTING_net_new[,clean_no_TESTING_net_new]
TESTING<-TESTING[,clean_no_TESTING]

dim(TESTING_net_new)
dim(TESTING)

head(TESTING[1:10,1:10])
head(TESTING_net_new[1:10,1:10])


