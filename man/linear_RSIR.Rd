% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/linear_RSIR.R
\name{do.rsir}
\alias{do.rsir}
\title{Regularized Sliced Inverse Regression}
\usage{
do.rsir(
  X,
  response,
  ndim = 2,
  h = max(2, round(nrow(X)/5)),
  preprocess = c("center", "scale", "cscale", "decorrelate", "whiten"),
  regmethod = c("Ridge", "Tikhonov", "PCA", "PCARidge", "PCATikhonov"),
  tau = 1,
  numpc = ndim
)
}
\arguments{
\item{X}{an \eqn{(n\times p)} matrix or data frame whose rows are observations
and columns represent independent variables.}

\item{response}{a length-\eqn{n} vector of response variable.}

\item{ndim}{an integer-valued target dimension.}

\item{h}{the number of slices to divide the range of response vector.}

\item{preprocess}{an additional option for preprocessing the data.
Default is "center". See also \code{\link{aux.preprocess}} for more details.}

\item{regmethod}{type of regularization scheme to be used.}

\item{tau}{regularization parameter for adjusting rank-deficient scatter matrix.}

\item{numpc}{number of principal components to be used in intermediate dimension reduction scheme.}
}
\value{
a named list containing
\describe{
\item{Y}{an \eqn{(n\times ndim)} matrix whose rows are embedded observations.}
\item{trfinfo}{a list containing information for out-of-sample prediction.}
\item{projection}{a \eqn{(p\times ndim)} whose columns are basis for projection.}
}
}
\description{
One of possible drawbacks in SIR method is that for high-dimensional data, it might suffer from
rank deficiency of scatter/covariance matrix. Instead of naive matrix inversion, several have
proposed regularization schemes that reflect several ideas from various incumbent methods.
}
\examples{
## generate swiss roll with auxiliary dimensions
## it follows reference example from LSIR paper.
set.seed(100)
n     = 50
theta = runif(n)
h     = runif(n)
t     = (1+2*theta)*(3*pi/2)
X     = array(0,c(n,10))
X[,1] = t*cos(t)
X[,2] = 21*h
X[,3] = t*sin(t)
X[,4:10] = matrix(runif(7*n), nrow=n)

## corresponding response vector
y = sin(5*pi*theta)+(runif(n)*sqrt(0.1))

## try with different regularization methods
## use default number of slices
out1 = do.rsir(X, y, regmethod="Ridge")
out2 = do.rsir(X, y, regmethod="Tikhonov")
outsir = do.sir(X, y)

## visualize
opar <- par(no.readonly=TRUE)
par(mfrow=c(1,3))
plot(out1$Y,   main="RSIR::Ridge")
plot(out2$Y,   main="RSIR::Tikhonov")
plot(outsir$Y, main="standard SIR")
par(opar)

}
\references{
\insertRef{chiaromonte_dimension_2002}{Rdimtools}

\insertRef{zhong_rsir_2005}{Rdimtools}

\insertRef{bernard-michel_gaussian_2009}{Rdimtools}

\insertRef{bernard-michel_retrieval_2009}{Rdimtools}
}
\seealso{
\code{\link{do.sir}}
}
\author{
Kisung You
}
\concept{linear_methods}
