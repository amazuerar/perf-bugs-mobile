##################################################################################
# SET YOUR PATH HERE
##################################################################################
setwd(".")

##################################################################################

# READS THE TABLE
t<-read.csv("bug-fixing-commits-performance.csv")
#t<-read.csv("bug-fixing-commits-non-performance.csv")

##################################################################################
##################################################################################

# METRICS

##################################################################################
repo_related=c("releases_pre_fixing_commit","issues_pre_fixing_commit","open_issues_pre_fixing_commit","closed_issues_pre_fixing_commit","age","LOC","Contributors")

code_related=c("mean_code_frequency_addition","median_code_frequency_addition","mean_code_frequency_deletion","median_code_frequency_deletion")

patch_related=c("patch_total_modifications","patch_total_deletions","patch_total_additions")
##################################################################################
##################################################################################

# CORRELATION ANALYSIS

##################################################################################
library(Hmisc)

#select here the combineation where you want to compute correlations
allMetrics=c(repo_related,code_related,patch_related)

t2<-subset(t,select=allMetrics)
mx<-na.omit((t2))
v<-varclus(as.matrix(mx,similarity="spearman",type="data.matrix"))
plot(v)
Threshold=0.7**2
a<-cutree(v$hclust,h=1-Threshold)
write.csv(a,file="prunemetrics.csv",row.names=TRUE,quote=FALSE)
a

# PICK ONE METRICS PER OBTAINED CLUSTER
metrics=c("releases_pre_fixing_commit","issues_pre_fixing_commit","age","LOC","Contributors","mean_code_frequency_addition","patch_total_modifications")
##################################################################################
##################################################################################

# NORMALIZATION

##################################################################################
range01 <- function(x){(x-min(x,na.rm=TRUE))/(max(x,na.rm = TRUE)-min(x,na.rm=TRUE))}
res <- data.frame(matrix(ncol = (length(metrics)+2), nrow = nrow(t)))
colnames(res) <- c(metrics,"days_needed_to_remove_min","days_needed_to_remove_max")

for(metric in metrics){
	res[[metric]]=range01(t[[metric]])
}

res[["days_needed_to_remove_min"]] = t[["days_needed_to_remove_min"]]
res[["days_needed_to_remove_max"]] = t[["days_needed_to_remove_max"]]

##################################################################################
##################################################################################

# COXPH MODEL

##################################################################################
library(survival)

metrics_to_print_in_model<-""
for(metric in metrics){
  metrics_to_print_in_model <- paste(metrics_to_print_in_model,metric,"+",sep="")
}
metrics_to_print_in_model <- substr(metrics_to_print_in_model,0,nchar(metrics_to_print_in_model)-1)

metrics_to_print_in_model

#Since all bugs have been killed, we put 1 to indicate their death in the survivability model
status<-seq(1,1,length.out=nrow(res))

#CHANGE HERE days_needed_to_remove_min/max for the other survivability model
surv_model=Surv(res$days_needed_to_remove_max,status)

m<-coxph(surv_model~releases_pre_fixing_commit+issues_pre_fixing_commit+age+LOC+Contributors+mean_code_frequency_addition+patch_total_modifications, data=res)

summary(m)

#days_needed_to_remove_min
#                                coef exp(coef) se(coef)      z Pr(>|z|)   
#releases_pre_fixing_commit   -0.9725    0.3781   0.5885 -1.652  0.09846 . 
#issues_pre_fixing_commit     -0.2594    0.7715   0.3430 -0.756  0.44961   
#age                          -1.0834    0.3385   0.3862 -2.805  0.00503 **
#LOC                          -0.7526    0.4711   0.3275 -2.298  0.02157 * 
#Contributors                  0.1737    1.1897   0.2774  0.626  0.53107   
#mean_code_frequency_addition  0.2088    1.2322   0.2300  0.908  0.36403   
#patch_total_modifications     1.3549    3.8765   0.5196  2.608  0.00911 **
#---
#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
#                             exp(coef) exp(-coef) lower .95 upper .95
#releases_pre_fixing_commit      0.3781     2.6445    0.1193    1.1984
#issues_pre_fixing_commit        0.7715     1.2961    0.3939    1.5113
#age                             0.3385     2.9546    0.1588    0.7215
#LOC                             0.4711     2.1226    0.2479    0.8952
#Contributors                    1.1897     0.8405    0.6908    2.0491
#mean_code_frequency_addition    1.2322     0.8116    0.7850    1.9340
#patch_total_modifications       3.8765     0.2580    1.4002   10.7323
#
#Concordance= 0.635  (se = 0.017 )
#Likelihood ratio test= 51.84  on 7 df,   p=6e-09
#Wald test            = 48.53  on 7 df,   p=3e-08
#Score (logrank) test = 51.24  on 7 df,   p=8e-09

##################################################################################
##################################################################################

#days_needed_to_remove_max
#releases_pre_fixing_commit   -2.45761   0.08564  0.79902 -3.076   0.0021 ** 
#issues_pre_fixing_commit     -0.15682   0.85486  0.35399 -0.443   0.6578    
#age                          -3.24335   0.03903  0.48946 -6.626 3.44e-11 ***
#LOC                           0.08772   1.09168  0.33345  0.263   0.7925    
#Contributors                  0.17221   1.18793  0.30975  0.556   0.5782    
#mean_code_frequency_addition -0.33140   0.71792  0.22379 -1.481   0.1387    
#patch_total_modifications    -0.52477   0.59169  0.73174 -0.717   0.4733    
#---
#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
#                             exp(coef) exp(-coef) lower .95 upper .95
#releases_pre_fixing_commit     0.08564    11.6768   0.01789    0.4100
#issues_pre_fixing_commit       0.85486     1.1698   0.42715    1.7108
#age                            0.03903    25.6194   0.01496    0.1019
#LOC                            1.09168     0.9160   0.56788    2.0986
#Contributors                   1.18793     0.8418   0.64734    2.1800
#mean_code_frequency_addition   0.71792     1.3929   0.46300    1.1132
#patch_total_modifications      0.59169     1.6901   0.14101    2.4829
#
#Concordance= 0.67  (se = 0.017 )
#Likelihood ratio test= 115.8  on 7 df,   p=<2e-16
#Wald test            = 91.24  on 7 df,   p=<2e-16
#Score (logrank) test = 95.4  on 7 df,   p=<2e-16