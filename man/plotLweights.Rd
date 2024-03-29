% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotLweights.R
\name{plotLweights}
\alias{plotLweights}
\title{Distribution rank comparison}
\usage{
plotLweights(
  dlf,
  type = "o",
  col = RColorBrewer::brewer.pal(5, "Set2"),
  pch = c(1:4, NA),
  lty = 1,
  lwd = 1,
  legargs = NULL,
  main = "Distribution function GOF and weights",
  xlab = "Weight / RMSE",
  ylab = "",
  xlim = range(gof[, grep("weight", colnames(gof))], na.rm = TRUE),
  ...
)
}
\arguments{
\item{dlf}{List as returned by \code{\link{distLfit}}, containing the element \code{gof}}

\item{type, col, pch, lty, lwd}{Vectors with 5 values for line customization. Recycled if necessary.}

\item{legargs}{List of arguments passed to \code{\link{legend}}, like cex, bg, etc.}

\item{main, xlab, ylab}{plot title and axis labels}

\item{xlim}{Range of x axis. DEFAULT: range(gof$weight*)}

\item{\dots}{Further arguments passed to \code{\link{plot}}.}
}
\value{
None.
}
\description{
Plot rank comparison of fitted distributions calculated by \code{\link{distLfit}}.
}
\examples{
# see distLweights and distLfit

}
\seealso{
\code{\link{distLweights}}, \code{\link{distLfit}}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, Sept 2014
}
\keyword{distribution}
\keyword{hplot}
