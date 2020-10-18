suppressPackageStartupMessages(library(doParallel))
cluster <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cluster)

set.seed(123)

choice<-1
use_best<-"yes"

# chosen in model explorer...
# foldsx<-10
# repeatsx<-5

sample_portion<-.7
gbmFit_dotx
(shrinkagex<-best_alternative_models[choice,2])
(interactiondepthx<-best_alternative_models[choice,3])
(nminobsinnodex<-best_alternative_models[choice,4])
(ntreesx<-best_alternative_models[choice,5])

if(use_best=="yes") (shrinkagex<-gbmFit_dotx$results[best(gbmFit_dotx$results, "Accuracy", maximize = T),1])
if(use_best=="yes") (interactiondepthx<-gbmFit_dotx$results[best(gbmFit_dotx$results, "Accuracy", maximize = T),2])
if(use_best=="yes") (nminobsinnodex<-gbmFit_dotx$results[best(gbmFit_dotx$results, "Accuracy", maximize = T),3]);
if(use_best=="yes") (ntreesx<-gbmFit_dotx$results[best(gbmFit_dotx$results, "Accuracy", maximize = T),4])

main<-no_final

impute_methodx<-c("center","scale","YeoJohnson")
#impute_methodx<-c("center","scale")

(basex<-nrow(main))
samplex<-sample(basex, floor(sample_portion*basex))
dfx<-main[samplex,]

system.time(impute<-preProcess(dfx[,-1], method = impute_methodx, allowParallel=T))
preprocessed<-predict(impute, dfx[,-1])

gbmGrid<-expand.grid(interaction.depth = interactiondepthx,
                        n.trees = ntreesx,
                        shrinkage = shrinkagex,
                        n.minobsinnode = nminobsinnodex)
nrow(gbmGrid)
head(gbmGrid)

fitControl<-trainControl(method = "repeatedcv", number = foldsx, repeats = repeatsx, allowParallel = T)

set.seed(825)

gbmFit_dotxfinal <- train(y=dfx$classe, x = preprocessed,
                 method = "gbm",
                 trControl = fitControl,
                 verbose = FALSE,
                 tuneGrid = gbmGrid)

pred_dfx<-data.frame(ground_truth=dfx$classe, prediction=predict(gbmFit_dotxfinal,preprocessed))
confusionMatrix(pred_dfx$prediction, pred_dfx$ground_truth)

freshy<-main[-samplex,]
preprocessed_freshy<-predict(impute, freshy[,-1])
pred_freshy<-data.frame(ground_truth=freshy$classe, prediction=predict(gbmFit_dotxfinal,preprocessed_freshy))
confusionMatrix(pred_freshy$prediction, pred_freshy$ground_truth)

preprocessed_TESTING_net_new<-predict(impute, TESTING_net_new[,-31])
pred_TESTING_net_new<-data.frame(ground_truth=TESTING_net_new$classe, prediction=predict(gbmFit_dotxfinal,preprocessed_TESTING_net_new))
confusionMatrix(pred_TESTING_net_new$prediction, pred_TESTING_net_new$ground_truth)

stopCluster(cluster)
registerDoSEQ()

##########################################
# check the real stuff...
temptesting<-data.frame(read_csv("pml-testing.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
tempreal<-data.frame(read_csv("WearableComputing_weight_lifting_exercises_biceps_curl_variations.csv", na=c("NA", "#DIV/0!")), stringsAsFactors = F)
t<-temptesting%>%select(user_name, raw_timestamp_part_1, raw_timestamp_part_2, gyros_belt_x, gyros_belt_y)
j<-predict(impute, TESTING)
p<-predict(gbmFit_dotxfinal, j)
combo<-data.frame(cbind(t,p))
(r<-tempreal%>%select(user_name, raw_timestamp_part_1, raw_timestamp_part_2, gyros_belt_x, gyros_belt_y, classe)%>%inner_join(combo)%>%mutate(good=classe==p))
##########################################
nrow(dfx)
round(confusionMatrix(pred_dfx$prediction, pred_dfx$ground_truth)$overall,3)
nrow(freshy)
round(confusionMatrix(pred_freshy$prediction, pred_freshy$ground_truth)$overall,3)
nrow(TESTING_net_new)
round(confusionMatrix(pred_TESTING_net_new$prediction, pred_TESTING_net_new$ground_truth)$overall,3)
nrow(r)
sum(r$good/20)

