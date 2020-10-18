Welcome to GitHub Pages

You can use the editor on GitHub to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run Jekyll to rebuild the pages in your site, from the content in your Markdown files.

Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
For more details see GitHub Flavored Markdown.

Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your repository settings. The name of this theme is saved in the Jekyll _config.yml configuration file.

Support or Contact

Having trouble with Pages? Check out our documentation or contact support and well help you sort it out.

---
title: "Practical Machine Learning course project"
author: "Ray Bem"
date: "10/17/2020"
output:
  html_document: default
  pdf_document: default
---
## Synopsis

### Exploratory Data Analysis

The data came in the form of a comma separated file with 160 features and 19,622 observations.  Sample prints and diagnostics identified a small subset of variables that we set aside as they describe elements not included in this effort.  For example, the `user_name` variable adds a user-specific dimension if included in the models, we are trying to build here a classifier independent of user.  These variables included in the original data, are left out:

**variable**|**description**|**reason left out**
------------|----------------|--------------------
user_name|study participant name|we want to predict classe for any person, therefore removed
cvtd_timestamp|converted timestamp|we disregard time in this analysis
X1|unnamed variable|a sequential record id|obviously this would distort the model if left in
raw_timestamp_part_1|raw timestamp part 1|we disregard time in this analysis
raw_timestamp_part_2|raw timestamp part 2|we disregard time in this analysis
num_window|time window identifier|
new_window|identifies new time windows, summarizes detail data|separated these data out altogether (n=406)

With the number of variables high enough to be difficult to view, summary functions were used to highlight characteristics.  The first aspect examined was the `new_window` variable.  This was determined to be a summarization of detail records tagged with "no", and set aside early in the code.  In these "yes" data, most columns had more data for several fields, when compared with the "no" data.  As our goal is the simplest classifier as possible, and the summary data looked so much different than the bulk of the data, these were left out (n=406).  The remainder of this analysis focuses on the "no" data, n=19,216 records.

#### Highly correlated variable reduction
The `cor` function was used to identify correlations above XXXXX percent, the user sets the cutoff value at the top of the code. When set at .8, we found ```nrow(filter(varmap, is.na(high_corr_no)==F))``` highly correlated variables in the "no" new_window data.  As we know the nature of the measurements should include things that will correlate (there are only three dimensions being measured on a single body with a limited, intended motion), we leave some correlated covariates in the model (i.e., we don't exclude all correlated varaiables).

#### Low or near-zero variance variable reduction
In a similar fashion, the r function `nearzeroVariance` was used to identify variables that would add little additional information to our models.  We again examined the output and concluded these would be left out.  This process identified `r nrow(filter(varmap, is.na(nzv_no)==T))` variables with low variance, these were removed.

#### Missing data
Finally, missing data were explored.  At this point we have only the detail "no" data, and highly correlated and near-zero variance variables have been removed.  We observe no missing data, therefore our model choices do not require any imputation of data.

#### Final data
This yields a final modelling dataset having the following characteristics...

## Building the classification model
A *modelling process* was built to more easily explore the data.  The R package `caret` was used to create data partitions separating training data into a set to build models on, and a set to test.  These test data are used afterwards to assess our estimated out of sample error rate (for application to new study subjects).  For model exploration, the code allows the user to adjust the proportion of training/test, the exploration used 10% of the training data.  

The summarized model results were then examined and the model chosen.  The user can set the option to select what R considers the "best" model, or the user can choose a less precise version of the model, in consideration of overtraining.  For example, the best model/tree may be overfitted to the data, therefore a less precise but more simplified (in terms of number of trees, etc) version may be desired for fitting on brand new data.  The user can easily select from the top five "next best" models generated from the grid. 

#### Gradient Boosting Model (gbm)
A `caret` grid of model tuning features was built to generate estimates using a variety of tuning parameters.  These results are presented graphically in APPENDIX???.  One can see the increase in model performance as we adjust both the restrictiveness of the model (a la requiring more or less as a minimum in each branch of the trees), as well as how much information is retained for future branch development (a la shrinkage).  The interaction depth was also varied.  

#### Bagged, Boosted Trees (treebag)
A second model was built for comparison, an effort to see just how different the models would be in their classification.  For this model, no tuning features exist, and we observed a much faster processing time.  

## Cross Validation
Cross validation was performed using 10-folds of the training data, repeated five times.  The resampling distributions are presented graphically in APPENDIX????.  

## Choices made

## Summary





























