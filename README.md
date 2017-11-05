### intro

Fit, plot and compare several (extreme value) distributions. 
Can also compute (truncated) distribution quantile estimates and draw a plot with return periods on a linear scale.

**See the [Vignette](https://cran.r-project.org/package=extremeStat/vignettes/extremeStat.html) for an introduction to the package.**

### installation

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version-last-release/extremeStat)](https://cran.r-project.org/package=extremeStat) 
[![downloads](http://cranlogs.r-pkg.org/badges/extremeStat)](http://www.r-pkg.org/services)
[![Rdoc](http://www.rdocumentation.org/badges/version/extremeStat)](http://www.rdocumentation.org/packages/extremeStat)


Install / load the package and browse through the examples:
```R
install.packages("extremeStat")
library(extremeStat)
vignette(extremeStat)

# update to the current development version:
berryFunctions::instGit("brry/extremeStat")
```

### trouble

If direct installation from CRAN doesn't work, your R version might be too old. In that case, an update is really recommendable: [r-project.org](https://www.r-project.org/). If you can't update R, try installing from source (github) via `instGit` or devtools as mentioned above. If that's not possible either, here's a manual workaround:
click on **Clone or Download - Download ZIP** (topright, [link](https://github.com/brry/extremeStat/archive/master.zip)), unzip the file to some place, then
```R
setwd("that/path")
dd <- dir("extremeStat-master/R", full=T)
dummy <- sapply(dd, source)
```
This creates all R functions as objects in your globalenv workspace (and overwrites existing objects of the same name!).
