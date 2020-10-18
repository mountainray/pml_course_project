
# trellis.par.set(caretTheme())
# plot.new()
# par(mfrow=c(1,3))
# densityplot(adaFit_dotx, pch=23)
# densityplot(treebagFit_dotx, pch='|')
# densityplot(rfFit_dotx, pch='|')

adaplot<-ggplot(adaFit_dotx)+ggtitle("adaFit_dotx")
treebagplot<-ggplot(treebagFit_dotx)+ggtitle("treebagFit_dotx")
grid.arrange(adaplot, rfplot, treebagplot)

adaplot<-ggplot(adaFit_dotx)+ggtitle("adaFit_dotx")
rfplot<-ggplot(rfFit_dotx)+ggtitle("rfFit_dotx")
gbmplot<-ggplot(gbmFit_dotx)+ggtitle("gbmFit_dotxfinal")
grid.arrange(adaplot, rfplot, gbmFit_dotx)

resamps<-resamples(list(
	gbm = gbmFit_dotx,
#	adabag = adaFit_dotx,
	treebag = treebagFit_dotx))
resamps

summary(resamps)
difValues <- diff(resamps)
difValues
summary(difValues)

trellis.par.set(theme1)
bwplot(difValues, layout = c(3, 1))
splom(resamps)
theme1 <- trellis.par.get()
theme1$plot.symbol$col = rgb(.2, .2, .2, .4)
theme1$plot.symbol$pch = 16
theme1$plot.line$col = rgb(1, 0, 0, .7)
theme1$plot.line$lwd <- 2
trellis.par.set(theme1)
xyplot(resamps, what = "BlandAltman")

theme1 <- trellis.par.get()
theme1$plot.symbol$col = rgb(.2, .2, .2, .4)
theme1$plot.symbol$pch = 16
theme1$plot.line$col = rgb(1, 0, 0, .7)
theme1$plot.line$lwd <- 2
trellis.par.set(theme1)
bwplot(resamps, layout = c(3, 1))

names(resamps)
resamps$metrics
trellis.par.set(caretTheme())
dotplot(resamps, metric = c("Accuracy", "Kappa"))

# trellis.par.set(caretTheme())
# plot(gbmFit_dotx, metric = "Accuracy")
#
# trellis.par.set(caretTheme())
# plot(adaFit_dotx, metric = "Accuracy")

# trellis.par.set(caretTheme())
# plot(treebagFit_dotx, metric = "Accuracy")


# ###########################
# twoClassSim(1000)
# trellis.par.set(caretTheme())
# lift_obj <- lift(classe ~ FDA + LDA + C5.0, data = lift_results)
# plot(lift_obj, values = 60, auto.key = list(columns = 3,
#                                             lines = TRUE,
#                                             points = FALSE))