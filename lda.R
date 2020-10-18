suppressPackageStartupMessages(library(doParallel))
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)

set.seed(123)

main<-no_final

foldsx<-10
repeatsx<-5
# foldsx<-2
# repeatsx<-2

impute_methodx<-c("center","scale","YeoJohnson", "bagImpute")
impute_methodx<-c("center","scale","YeoJohnson")
#impute_methodx<-c("YeoJohnson")

(basex<-nrow(main))
samplex<-sample(basex, floor(.1*basex))
dfx<-main[samplex,]

system.time(impute<-preProcess(dfx[,-1], method = impute_methodx, allowParallel=T))
preprocessed<-predict(impute, dfx[,-1])

#gbmGrid<-expand.grid(mtry = c(1:5))
gbmGrid<-expand.grid(mtry = c(1:5), maxdepth=c(1,5,10))
nrow(gbmGrid)
head(gbmGrid)

fitControl<-trainControl(method = "repeatedcv", number = foldsx, repeats = repeatsx, allowParallel = T)

set.seed(825)

ldaFit_dotx <- train(y=dfx$classe, x = preprocessed,
#                 method = "rf",
                 method = "lda",
                 trControl = fitControl,
                 verbose = FALSE
		     )

pred_dfx<-data.frame(ground_truth=dfx$classe, prediction=predict(ldaFit_dotx,preprocessed))
confusionMatrix(pred_dfx$prediction, pred_dfx$ground_truth)

freshy<-main[-samplex,]
preprocessed_freshy<-predict(impute, freshy[,-1])
pred_freshy<-data.frame(ground_truth=freshy$classe, prediction=predict(ldaFit_dotx,preprocessed_freshy))
confusionMatrix(pred_freshy$prediction, pred_freshy$ground_truth)

TESTING_net_newx<-TESTING_net_new%>%mutate(roll_dumbbell=ifelse(is.na(roll_dumbbell)==T, mean(TESTING_net_new$roll_dumbbell, na.rm = T), roll_dumbbell))
preprocessed_TESTING_net_newx<-predict(impute, TESTING_net_newx[,-31])
pred_TESTING_net_newx<-data.frame(ground_truth=TESTING_net_newx$classe, prediction=predict(ldaFit_dotx,preprocessed_TESTING_net_newx))
confusionMatrix(pred_TESTING_net_newx$prediction, pred_TESTING_net_newx$ground_truth)

# pred_dfx<-data.frame(ground_truth=dfx$classe, prediction=predict(ldaFit_dotx,preprocessed))
# confusionMatrix(pred_dfx$prediction, pred_dfx$ground_truth)
#
# freshy<-main[-samplex,]
# preprocessed_freshy<-predict(impute, freshy[,-1])
# pred_rpart<-data.frame(ground_truth=freshy$classe, prediction=predict(ldaFit_dotx,preprocessed_freshy))
# confusionMatrix(pred_rpart$prediction, pred_rpart$ground_truth)
#
# preprocessed_TESTING<-predict(impute, TESTING_net_new[,-31])
# pred_rpart<-data.frame(ground_truth=TESTING_net_new$classe, prediction=predict(ldaFit_dotx,preprocessed_TESTING))
# confusionMatrix(pred_rpart$prediction, pred_rpart$ground_truth)

stopCluster(cluster)
registerDoSEQ()

trellis.par.set(caretTheme())
plot(ldaFit_dotx, metric = "Accuracy", plotType = "level",
#plot(ldaFit_dotx, metric = "Kappa", plotType = "level",
     scales = list(x = list(rot = 90)), main="ldaFit_dotx")

(xx<-ggplot(ldaFit_dotx, main="ldaFit_dotx")+ggtitle("xx"))

best_within_1pct<-cbind(tolerance="within 1 pct", ldaFit_dotx$results[tolerance(ldaFit_dotx$results, metric = "Accuracy", tol = 1, maximize = TRUE),1:4])
best_within_2pct<-cbind(tolerance="within 2 pct", ldaFit_dotx$results[tolerance(ldaFit_dotx$results, metric = "Accuracy", tol = 2, maximize = TRUE),1:4])
best_within_3pct<-cbind(tolerance="within 3 pct", ldaFit_dotx$results[tolerance(ldaFit_dotx$results, metric = "Accuracy", tol = 3, maximize = TRUE),1:4])
best_within_4pct<-cbind(tolerance="within 4 pct", ldaFit_dotx$results[tolerance(ldaFit_dotx$results, metric = "Accuracy", tol = 4, maximize = TRUE),1:4])
best_within_5pct<-cbind(tolerance="within 5 pct", ldaFit_dotx$results[tolerance(ldaFit_dotx$results, metric = "Accuracy", tol = 5, maximize = TRUE),1:4])

(best_alternative_models<-rbind(best_within_1pct, best_within_2pct, best_within_3pct, best_within_4pct, best_within_5pct))

##########################################
# check the real stuff...
temptesting<-data.frame(read_csv("pml-testing.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
tempreal<-data.frame(read_csv("WearableComputing_weight_lifting_exercises_biceps_curl_variations.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
t<-temptesting%>%select(user_name, raw_timestamp_part_1, raw_timestamp_part_2, gyros_belt_x, gyros_belt_y)
j<-predict(impute, TESTING)
p<-predict(ldaFit_dotx, j)
combo<-data.frame(cbind(t,p))
(r<-tempreal%>%select(user_name, raw_timestamp_part_1, raw_timestamp_part_2, gyros_belt_x, gyros_belt_y, classe)%>%inner_join(combo)%>%mutate(good=classe==p))
##########################################
nrow(dfx)
round(confusionMatrix(pred_dfx$prediction, pred_dfx$ground_truth)$overall,3)
nrow(freshy)
round(confusionMatrix(pred_freshy$prediction, pred_freshy$ground_truth)$overall,3)
nrow(TESTING_net_newx)
nrow(TESTING_net_new)
round(confusionMatrix(pred_TESTING_net_newx$prediction, pred_TESTING_net_newx$ground_truth)$overall,3)
nrow(r)
sum(r$good/20)

