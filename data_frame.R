high_correlation_cutoff_no<-.8
high_correlation_cutoff_yes<-.8

original_training<-data.frame(read_csv("pml-training.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
TESTING<-data.frame(read_csv("pml-testing.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
TESTING
########################################
TESTING_net_new<-data.frame(read_csv("WearableComputing_weight_lifting_exercises_biceps_curl_variations.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)

names(TESTING_net_new)[which(!names(TESTING_net_new) %in% names(original_training))]
names(original_training)[which(!names(original_training) %in% names(TESTING_net_new))]
TESTING_net_new<-setdiff(TESTING_net_new[,-15],original_training[,-c(1,16)])

head(TESTING_net_new[1:10,1:10])
########################################


#TESTING<-data.frame(read_csv("pml-testing.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
dim(original_training)
names(original_training)
str(original_training[,1:10])
varmap_original<-data.frame(
	varname=colnames(original_training),
	varindex=c(1:length(colnames(original_training))), stringsAsFactors = F)
vartypes<-data.frame(typex=sapply(original_training, typeof), varname=colnames(original_training), stringsAsFactors = F)
varmap_original<-left_join(varmap_original, vartypes)
dim(original_training)

# split off junk variables, but have them avaialable as needed...
junk_frame<-select(original_training, user_name, cvtd_timestamp, new_window, X1, raw_timestamp_part_1, raw_timestamp_part_2, num_window)
head(junk_frame)

# remove the summary records here, maybe deal with later (new_window=="yes")
training_new_window_no<-filter(original_training, new_window=="no")%>%select(-c(user_name, cvtd_timestamp, X1, raw_timestamp_part_1, raw_timestamp_part_2, num_window, new_window))
training_new_window_yes<-filter(original_training, new_window=="yes")%>%select(-c(user_name, cvtd_timestamp, X1, raw_timestamp_part_1, raw_timestamp_part_2, num_window, new_window))
head(training_new_window_no[1:10,1:10])
head(training_new_window_yes[1:10,1:10])

# reorder columns, character variables up front for easier subsetting
df_charvars_check<-data.frame(sapply(names(training_new_window_no), function(x){is.character(training_new_window_no[,x])}))
newvarlist<-c(which(df_charvars_check>0),which(df_charvars_check<1))
training_new_window_no<-training_new_window_no[,newvarlist]
str(training_new_window_no[,1:10])
dim(training_new_window_no)

df_charvars_check<-data.frame(sapply(names(training_new_window_yes), function(x){is.character(training_new_window_yes[,x])}))
newvarlist<-c(which(df_charvars_check>0),which(df_charvars_check<1))
training_new_window_yes<-training_new_window_yes[,newvarlist]
dim(training_new_window_yes)
head(training_new_window_yes[1:10,1:10])

# identify very low variance variables
nzv_no<-data.frame(nearZeroVar(training_new_window_no, saveMetrics = T), varname=names(training_new_window_no), nzv_no=rep("no", length(names(training_new_window_no))), stringsAsFactors = F)%>%filter(zeroVar==TRUE & near(percentUnique,0))
dim(nzv_no)
nzv_yes<-data.frame(nearZeroVar(training_new_window_yes, saveMetrics = T), varname=names(training_new_window_yes), nzv_yes=rep("yes", length(names(training_new_window_yes))), stringsAsFactors = F)%>%filter(zeroVar==TRUE & near(percentUnique,0))
dim(nzv_yes)

(lst_nzv_reductions_no<-which(names(training_new_window_no) %in% as.list(nzv_no$name)))
(lst_nzv_reductions_yes<-which(names(training_new_window_yes) %in% as.list(nzv_yes$name)))

# identify high correlation variables, will remove later, adjust cutoff
corr_matrix<-abs(cor(training_new_window_no[,-1]))
diag(corr_matrix)<-0
high_corr_no<-unique(names(which(corr_matrix>high_correlation_cutoff_no, arr.ind = T)[,1]))
(lst_high_corr_no<-which(names(training_new_window_no) %in% high_corr_no))

corr_matrix<-abs(cor(training_new_window_yes[,-1]))
diag(corr_matrix)<-0
high_corr_yes<-unique(names(which(corr_matrix>high_correlation_cutoff_yes, arr.ind = T)[,1]))
(lst_high_corr_yes<-which(names(training_new_window_yes) %in% high_corr_yes))


######### NEED TO DISTINGUISH YES NO VERSIONS OF DROPS IN VARMAP...!!!!!!!!!!!!!!!!!!!!!!!
nrow(nzv_yes)-nrow(inner_join(nzv_no, nzv_yes, by = c("freqRatio", "percentUnique", "zeroVar", "nzv", "varname")))
varmap<-left_join(varmap_original, data.frame(varname=names(junk_frame), source1="junk both", junk_status="junk"))%>%
	left_join(data.frame(varname=high_corr_no, high_corr_no=str_c("corr above ", high_correlation_cutoff_no)))%>%
	left_join(data.frame(varname=high_corr_yes, high_corr_yes=str_c("corr above ", high_correlation_cutoff_yes)))%>%
	left_join(nzv_no)%>%left_join(nzv_yes)
head(varmap,30)

clean_no<-which(names(training_new_window_no) %in% as.list(filter(varmap, is.na(junk_status)==T & is.na(nzv_no)==T & is.na(high_corr_no)==T))$varname)
clean_yes<-which(names(training_new_window_yes) %in% as.list(filter(varmap, is.na(junk_status)==T & is.na(nzv_yes)==T & is.na(high_corr_yes)==T))$varname)

no_final<-training_new_window_no[,clean_no]
head(no_final)
yes_final<-training_new_window_yes[,clean_yes]
head(yes_final)

# identify missing values
length(which(sapply(names(no_final), function(x) sum(is.na(no_final[,x]))>0)))
length(which(sapply(names(yes_final), function(x) sum(is.na(yes_final[,x]))>0)))

# update varmap
tmp<-data.frame(count_missing_no=sapply(names(no_final), function(x) sum(is.na(no_final[,x]))))
varmap<-left_join(varmap, data.frame(varname=rownames(tmp), tmp), by = "varname")
tmp<-data.frame(count_missing_yes=sapply(names(yes_final), function(x) sum(is.na(yes_final[,x]))))
varmap<-left_join(varmap, data.frame(varname=rownames(tmp), tmp), by = "varname")
