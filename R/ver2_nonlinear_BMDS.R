#' Bayesian Multidimensional Scaling
#'
#' A Bayesian formulation of classical Multidimensional Scaling is presented.
#' Even though this method is based on MCMC sampling, we only return maximum a posterior (MAP) estimate
#' that maximizes the posterior distribution. Due to its nature without any special tuning,
#' increasing \code{mc.iter} requires much computation. A note on the method is that
#' this algorithm does not return an explicit form of projection matrix so it's
#' classified in our package as a nonlinear method. Also, automatic dimension selection is not supported
#' for simplicity as well as consistency with other methods in the package.
#'
#' @param X an \eqn{(n\times p)} matrix or data frame whose rows are observations.
#' @param ndim an integer-valued target dimension.
#' @param par.a hyperparameter for conjugate prior on variance term, i.e., \eqn{\sigma^2 \sim IG(a,b)}. Note that \eqn{b} is chosen appropriately as in paper.
#' @param par.alpha hyperparameter for conjugate prior on diagonal term, i.e., \eqn{\lambda_j \sim IG(\alpha, \beta_j)}. Note that \eqn{\beta_j} is chosen appropriately as in paper.
#' @param par.step stepsize for random-walk, which is standard deviation of Gaussian proposal.
#' @param mc.iter the number of MCMC iterations.
#' @param preprocess  an additional option for preprocessing the data.
#' Default is "null". See also \code{\link{aux.preprocess}} for more details.
#' @param print.progress a logical; \code{TRUE} to show iterations, \code{FALSE} otherwise.
#'
#' @return a named list containing
#' \describe{
#' \item{Y}{an \eqn{(n\times ndim)} matrix whose rows are embedded observations.}
#' \item{trfinfo}{a list containing information for out-of-sample prediction.}
#' }
#'
#' @examples
#' \donttest{
#' ## load iris data
#' data(iris)
#' set.seed(100)
#' subid = sample(1:150,50)
#' X     = as.matrix(iris[subid,1:4])
#' label = as.factor(iris[subid,5])
#'
#' ## try different preprocessing
#' out1 <- do.bmds(X, ndim=2, preprocess="center")
#' out2 <- do.bmds(X, ndim=2, preprocess="cscale")
#' out3 <- do.bmds(X, ndim=2, preprocess="decorrelate")
#'
#' ## embeddings for each procedure
#' Y1 <- out1$Y; Y2 <- out2$Y; Y3 <- out3$Y
#'
#' ## visualize
#' opar <- par(no.readonly=TRUE)
#' par(mfrow=c(1,3))
#' plot(Y1, main="BMDS::iter=5",  col=label, pch=19)
#' plot(Y2, main="BMDS::iter=10", col=label, pch=19)
#' plot(Y3, main="BMDS::iter=50", col=label, pch=19)
#' par(opar)
#' }
#'
#' @references
#' \insertRef{oh_bayesian_2001}{Rdimtools}
#'
#' @rdname nonlinear_BMDS
#' @author Kisung You
#' @concept nonlinear_methods
#' @export
do.bmds <- function(X, ndim=2, par.a=5, par.alpha=0.5, par.step=1, mc.iter=50,
                    preprocess=c("null","center","scale","cscale","whiten",
                                 "decorrelate"), print.progress = FALSE){
  #------------------------------------------------------------------------
  # Preprocessing
  if (!is.matrix(X)){stop("* do.bmds : 'X' should be a matrix.")}
  myndim  = round(ndim)
  myprep  = ifelse(missing(preprocess), "null", match.arg(preprocess))
  mya     = as.double(par.a)
  myalpha = as.double(par.alpha)
  mystep  = as.double(par.step)
  myiter  = round(mc.iter)
  myprint = as.logical(print.progress)

  #------------------------------------------------------------------------
  # Computation : Let's use "maotai" package
  # 1. transformation
  tmplist = aux.preprocess.hidden(X,type=myprep,algtype="nonlinear")
  trfinfo = tmplist$info
  pX      = tmplist$pX

  # 2. use bmds from "maotai"
  Xsol    = maotai::bmds(pX, ndim=myndim, par.a=mya, par.alpha = myalpha,
                         par.step = mystep, mc.iter = myiter,
                         verbose = myprint)$embed
  #------------------------------------------------------------------------
  # Return
  result = list()
  result$Y = Xsol
  result$trfinfo = trfinfo
  return(result)

#
#
#   #------------------------------------------------------------------------
#   ## PREPROCESSING
#   #   1. data matrix
#   aux.typecheck(X)
#   n = nrow(X)
#   m = n*(n-1)/2
#   p = ncol(X)
#   #   2. ndim
#   ndim = as.integer(ndim)
#   if (!check_ndim(ndim,p)){
#     stop("* do.bmds : 'ndim' is a positive integer in [1,#(covariates)].")
#   }
#   #   3. preprocess
#   if (missing(preprocess)){
#     algpreprocess = "null"
#   } else {
#     algpreprocess = match.arg(preprocess)
#   }
#   #   4. preprocess
#   if (missing(preprocess)){
#     algpreprocess = "null"
#   } else {
#     algpreprocess = match.arg(preprocess)
#   }
#   #   5. other parameters
#   verbose = print.progress
#
#   #------------------------------------------------------------------------
#   # Preliminary Computation
#   # 0. transformation
#   tmplist = aux.preprocess.hidden(X,type=algpreprocess,algtype="nonlinear")
#   trfinfo = tmplist$info
#   pX      = tmplist$pX
#
#   # 1. apply CMDS for initialization
#   y     = as.matrix(base::scale(do.pca(pX, ndim=ndim)$Y, # (N x ndim) centered
#                                 center=TRUE, scale=FALSE))
#   Delta = as.matrix(stats::dist(y))           # (N x N) pairwise distances
#
#   # 2. initialization
#   distX  = as.matrix(stats::dist(pX))
#   eigy   = base::eigen(cov(y))
#   X0     = y%*%eigy$vectors    # (N x ndim) rotated
#   gamma0 = diag(X0)            # variances ?
#   sigg0  = bmds_compute_SSR(distX, Delta)/m; #
#   beta0  = apply(X0,2,var)/2
#
#   # 3. run the main part
#   runcpp <- main_bmds(distX, X0, sigg0, par.a, par.alpha, mc.iter, par.step, verbose, beta0)
#   Xsol   <- runcpp$solX
#
#   #------------------------------------------------------------------------
#   ## RETURN OUTPUT
#
#   result = list()
#   result$Y = Xsol
#   result$trfinfo = trfinfo
#   return(result)
}
