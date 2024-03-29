#' Extreme value stats
#' 
#' Extreme value statistics for flood risk estimation.
#' Input: vector with annual discharge maxima (or all observations for POT approach).
#' Output: discharge estimates for given return periods,
#' parameters of several distributions (fit based on L-moments),
#' quality of fits, plot with linear/logarithmic axis.
#' (plotting positions by Weibull and Gringorton).
#' 
#' @details \code{\link{plotLextreme}} adds weibull and gringorton plotting positions
#' to the distribution lines, which are estimated from the L-moments of the data itself.\cr
#' I personally believe that if you have, say, 35 values in \code{dat},
#' the highest return period should be around 36 years (Weibull) and not 60 (Gringorton).\cr
#' The plotting positions don't affect the distribution parameter estimation,
#' so this dispute is not really important.
#' But if you care, go ahead and google "weibull vs gringorton plotting positions".
#' 
#' Plotting positions are not used for fitting distributions, but for plotting only.
#' The ranks of ascendingly sorted extreme values are used to
#' compute the probability of non-exceedance Pn:\cr
#' \code{Pn_w <-  Rank      /(n+1)       # Weibull}\cr
#' \code{Pn_g <- (Rank-0.44)/(n+0.12)    # Gringorton (taken from lmom:::evplot.default)}\cr
#' Finally: RP = Return period = recurrence interval = 1/P_exceedance = 1/(1-P_nonexc.), thus:\cr
#' \code{RPweibull = 1/(1-Pn_w)} and analogous for gringorton.\cr
#' 
#' 
#' @return invisible dlf object, see \code{\link{printL}}.
#' The added element is \code{returnlev}, a data.frame with the return level (discharge)
#' for all given RPs and for each distribution.
#' Note that this differs from \code{\link{distLquantile}} (matrix output, not data.frame)
#' @note This function replaces \code{berryFunctions::extremeStatLmom}
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, 2012 (first draft) - 2014 & 2015 (main updates)
#' @seealso \code{\link{distLfit}}. \code{\link{distLexBoot}} for confidence
#'          interval from Bootstrapping.
#'          \code{\link[extRemes]{fevd}} in the package \code{extRemes}.
#' @references \url{https://RclickHandbuch.wordpress.com} Chapter 15 (German)\cr
#'             Christoph Mudersbach: Untersuchungen zur Ermittlung von hydrologischen
#'             Bemessungsgroessen mit Verfahren der instationaeren Extremwertstatistik
#' @keywords hplot dplot distribution ts
#' @export
#' @importFrom berryFunctions owa almost.equal
#' 
#' @examples
#' 
#' # Basic examples
#' # BM vs POT
#' # Plotting options
#' # weighted mean based on Goodness of fit (GOF)
#' # Effect of data proportion used to estimate GOF
#' # compare extremeStat with other packages
#' 
#' library(lmomco)
#' library(berryFunctions)
#' 
#' data(annMax) # annual streamflow maxima in river in Austria
#' 
#' # Basic examples ---------------------------------------------------------------
#' dlf <- distLextreme(annMax)
#' plotLextreme(dlf, log=TRUE)
#' plotLextreme(dlf, log="xy")
#' plotLextreme(dlf)
#' 
#' # Object structure:
#' str(dlf, max.lev=2)
#' printL(dlf)
#' 
#' # discharge levels for default return periods:
#' dlf$returnlev
#' 
#' # Estimate discharge that could occur every 80 years (at least empirically):
#' Q80 <- distLextreme(dlf=dlf, RPs=80)$returnlev
#' round(sort(Q80[1:17,1]),1)
#' # 99 to 143 m^3/s can make a relevant difference in engineering!
#' # That's why the rows weighted by GOF are helpful. Weights are given as in
#' plotLweights(dlf) # See also section weighted mean below
#' # For confidence intervals see ?distLexBoot
#' 
#' # Return period of a given discharge value, say 120 m^3/s:
#' round0(sort(1/(1-sapply(dlf$parameter, plmomco, x=120) )  ),1)
#' # exponential:                 every 29 years
#' # gev (general extreme value dist):  59,
#' # Weibull:                     every 73 years only
#' 
#' 
#' # BM vs POT --------------------------------------------------------------------
#' # Return levels by Block Maxima approach vs Peak Over Threshold approach:
#' # BM distribution theoretically converges to GEV, POT to GPD
#' 
#' data(rain, package="ismev")
#' days <- seq(as.Date("1914-01-01"), as.Date("1961-12-30"), by="days")
#' BM <- tapply(rain, format(days,"%Y"), max)  ;  rm(days)
#' dlfBM <- plotLextreme(distLextreme(BM, emp=FALSE), ylim=lim0(100), log=TRUE, nbest=10)
#' plotLexBoot(distLexBoot(dlfBM, quiet=TRUE), ylim=lim0(100))
#' plotLextreme(dlfBM, log=TRUE, ylim=lim0(100))
#' 
#' dlfPOT99 <- distLextreme(rain, npy=365.24, trunc=0.99, emp=FALSE)
#' dlfPOT99 <- plotLextreme(dlfPOT99, ylim=lim0(100), log=TRUE, nbest=10, main="POT 99")
#' printL(dlfPOT99)
#' 
#' # using only nonzero values (normally yields better fits, but not here)
#' rainnz <- rain[rain>0]
#' dlfPOT99nz <- distLextreme(rainnz, npy=length(rainnz)/48, trunc=0.99, emp=FALSE)
#' dlfPOT99nz <- plotLextreme(dlfPOT99nz, ylim=lim0(100), log=TRUE, nbest=10,
#'                            main=paste("POT 99 x>0, npy =", round(dlfPOT99nz$npy,2)))
#' 
#' \dontrun{ ## Excluded from CRAN R CMD check because of computing time
#' 
#' dlfPOT99boot <- distLexBoot(dlfPOT99, prop=0.4)
#' printL(dlfPOT99boot)
#' plotLexBoot(dlfPOT99boot)
#' 
#' 
#' dlfPOT90 <- distLextreme(rain, npy=365.24, trunc=0.90, emp=FALSE)
#' dlfPOT90 <- plotLextreme(dlfPOT90, ylim=lim0(100), log=TRUE, nbest=10, main="POT 90")
#' 
#' dlfPOT50 <- distLextreme(rain, npy=365.24, trunc=0.50, emp=FALSE)
#' dlfPOT50 <- plotLextreme(dlfPOT50, ylim=lim0(100), log=TRUE, nbest=10, main="POT 50")
#' }
#' 
#' ig99 <- ismev::gpd.fit(rain, dlfPOT99$threshold)
#' ismev::gpd.diag(ig99); title(main=paste(99, ig99$threshold))
#' \dontrun{
#' ig90 <- ismev::gpd.fit(rain, dlfPOT90$threshold)
#' ismev::gpd.diag(ig90); title(main=paste(90, ig90$threshold))
#' ig50 <- ismev::gpd.fit(rain, dlfPOT50$threshold)
#' ismev::gpd.diag(ig50); title(main=paste(50, ig50$threshold))
#' }
#' 
#' 
#' # Plotting options -------------------------------------------------------------
#' plotLextreme(dlf=dlf)
#' # Line colors / select distributions to be plotted:
#' plotLextreme(dlf, nbest=17, distcols=heat.colors(17), lty=1:5) # lty is recycled
#' plotLextreme(dlf, selection=c("gev", "gam", "gum"), distcols=4:6, PPcol=3, lty=3:2)
#' plotLextreme(dlf, selection=c("gpa","glo","wei","exp"), pch=c(NA,NA,6,8),
#'                  order=TRUE, cex=c(1,0.6, 1,1), log=TRUE, PPpch=c(16,NA), n_pch=20)
#' # use n_pch to say how many points are drawn per line (important for linear axis)
#' 
#' plotLextreme(dlf, legarg=list(cex=0.5, x="bottom", box.col="red", col=3))
#' # col in legarg list is (correctly) ignored

#' \dontrun{
#' ## Excluded from package R CMD check because it's time consuming
#' 
#' plotLextreme(dlf, PPpch=c(1,NA)) # only Weibull plotting positions
#' # add different dataset to existing plot:
#' distLextreme(Nile/15, add=TRUE, PPpch=NA, distcols=1, selection="wak", legend=FALSE)
#' 
#' # Logarithmic axis
#' plotLextreme(distLextreme(Nile), log=TRUE, nbest=8)
#' 
#' 
#' 
#' # weighted mean based on Goodness of fit (GOF) ---------------------------------
#' # Add discharge weighted average estimate continuously:
#' plotLextreme(dlf, nbest=17, legend=FALSE)
#' abline(h=115.6, v=50)
#' RP <- seq(1, 70, len=100)
#' DischargeEstimate <- distLextreme(dlf=dlf, RPs=RP, plot=FALSE)$returnlev
#' lines(RP, DischargeEstimate["weighted2",], lwd=3, col="orange")
#' 
#' # Or, on log scale:
#' plotLextreme(dlf, nbest=17, legend=FALSE, log=TRUE)
#' abline(h=115.9, v=50)
#' RP <- unique(round(logSpaced(min=1, max=70, n=200, plot=FALSE),2))
#' DischargeEstimate <- distLextreme(dlf=dlf, RPs=RP)$returnlev
#' lines(RP, DischargeEstimate["weighted2",], lwd=5)
#' 
#' 
#' # Minima -----------------------------------------------------------------------
#' 
#' browseURL("https://nrfa.ceh.ac.uk/data/station/meanflow/39072")
#' qfile <- system.file("extdata/discharge39072.csv", package="berryFunctions")
#' Q <- read.table(qfile, skip=19, header=TRUE, sep=",", fill=TRUE)[,1:2]
#' rm(qfile)
#' colnames(Q) <- c("date","discharge")
#' Q$date <- as.Date(Q$date)
#' plot(Q, type="l")
#' Qmax <- tapply(Q$discharge, format(Q$date,"%Y"), max)
#' plotLextreme(distLextreme(Qmax, quiet=TRUE))
#' Qmin <- tapply(Q$discharge, format(Q$date,"%Y"), min)
#' dlf <- distLextreme(-Qmin, quiet=TRUE, RPs=c(2,5,10,20,50,100,200,500))
#' plotLextreme(dlf, ylim=c(0,-31), yaxs="i", yaxt="n", ylab="Q annual minimum", nbest=14)
#' axis(2, -(0:3*10), 0:3*10, las=1)
#' -dlf$returnlev[c(1:14,21), ]
#' # Some distribution functions are an obvious bad choice for this, so I use
#' # weighted 3: Values weighted by GOF of dist only for the best half.
#' # For the Thames in Windsor, we will likely always have > 9 m^3/s streamflow
#' 
#' 
#' # compare extremeStat with other packages: ---------------------------------------
#' library(extRemes)
#' plot(fevd(annMax))
#' par(mfrow=c(1,1))
#' return.level(fevd(annMax, type="GEV")) # "GP", "PP", "Gumbel", "Exponential"
#' distLextreme(dlf=dlf, RPs=c(2,20,100))$returnlev["gev",]
#' # differences are small, but noticeable...
#' # if you have time for a more thorough control, please pass me the results!
#' 
#' 
#' # yet another dataset for testing purposes:
#' Dresden_AnnualMax <- c(403, 468, 497, 539, 542, 634, 662, 765, 834, 847, 851, 873,
#' 885, 983, 996, 1020, 1028, 1090, 1096, 1110, 1173, 1180, 1180,
#' 1220, 1270, 1285, 1329, 1360, 1360, 1387, 1401, 1410, 1410, 1456,
#' 1556, 1580, 1610, 1630, 1680, 1734, 1740, 1748, 1780, 1800, 1820,
#' 1896, 1962, 2000, 2010, 2238, 2270, 2860, 4500)
#' plotLextreme(distLextreme(Dresden_AnnualMax))
#' } # end dontrun
#' 
#' @param dat       Vector with \emph{either} (for Block Maxima Approach)
#'                  extreme values like annual discharge maxima \emph{or}
#'                  (for Peak Over Threshold approach) all values in time-series.
#'                  Ignored if dlf is given. DEFAULT: NULL
#' @param dlf       List as returned by \code{\link{distLfit}}. See also
#'                  \code{\link{distLquantile}}. Overrides dat! DEFAULT: NULL
#' @param RPs       Return Periods (in years) for which discharge is estimated.
#'                  DEFAULT: c(2,5,10,20,50)
#' @param npy       Number of observations per year. Leave \code{npy=1} if you
#'                  use annual block maxima (and leave truncate at 0).
#'                  If you use a POT approach (see \href{../doc/extremeStat}{vignette}
#'                  and examples below) e.g. on daily data, use npy=365.24.
#'                  DEFAULT: 1
#' @param truncate  Truncated proportion to determine POT threshold,
#'                  see \code{\link{distLquantile}}. DEFAULT: 0
#' @param quiet     Suppress notes and progbars? DEFAULT: FALSE
#' @param \dots     Further arguments passed to \code{\link{distLquantile}} like truncate, selection,
#'                  time, progbars
#' 
distLextreme <- function(
dat=NULL,
dlf=NULL,
RPs=c(2,5,10,20,50),
npy=1,
truncate=0,
quiet=FALSE,
... )
{
if(any(RPs<1.05) & !quiet) message("Note in distLextreme: for RPs=1 rather use min(dat).")
if(!almost.equal(npy,1) & almost.equal(truncate,0)) message("Note in distLextreme: ",
                    "npy != 1 but truncate == 0. for POT, it is recommended to use truncate.")
# (discharge) values at return periods:
datname <- deparse(substitute(dat))
dlf <- distLquantile(x=dat, dlf=dlf, probs=1-1/(RPs*npy), list=TRUE,
                     quiet=quiet, gpquiet=TRUE, truncate=truncate, datname=datname, ...)
returnlev <- dlf$quant
returnlev <- returnlev[, - ncol(returnlev), drop=FALSE]
# column names:
colnames(returnlev) <- paste0("RP.", RPs)
# Add to output:
#dlf$distnames <- NULL
#dlf$distcols <- NULL
#dlf$distselector <- "distLextreme" # remains distLfit for now
dlf$returnlev <- as.data.frame(returnlev)
dlf$npy <- npy
return(invisible(dlf))
} # end of function
