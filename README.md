# Investigating Types and Survivability of Performance Bugs in Mobile Apps

The data used in the study is available in the present repository established as an online appendix.

## Description

### RQ1 and RQ2 raw data

**Analyzed apps.xlsx** contains the list of the randomly selected 100 Android and 100 iOS apps hosted on GitHub. The 100 Android apps were extracted from the [open−source−android−apps project](https://github.com/pcqpcq/open-source-android-apps), i.e., a collection of open source Android apps, while the 100 iOS apps were collected from the similar [open−source−ios−apps project](https://github.com/dkhamsing/open-source-ios-apps).

**raw-data-rq1-rq2-list-of-applications-android** contains the list of Android apps having at least one analyzed commit in the present study. 

**raw-data-rq1-rq2-list-of-applications-ios** contains the list of iOS apps having at least one analyzed commit in the present study.

**raw-data-rq1-taxonomy** contains 500 commits (250 related to Android and 250 to iOS apps) aimed at fixing real performance bugs. Within the file can be found the commit url and a high level descriptive tag employed to create the taxonomies of performance bugs for Android and iOS apps.

**bug-fixing-commits-performance** contains the list of commits for which the SZZ algorithm was able to identify at least one performance-bug-inducing commit.

**bug-fixing-commits-non-performance** contains the list of commits for which the SZZ algorithm was able to identify at least one bug-inducing commit.

**script-factors-impacting-survivability** is the R script used to analyze the influence of the considered cofactors on the bugs survivability.
