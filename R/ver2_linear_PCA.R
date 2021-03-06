#' Principal Component Analysis
#'
#' \code{do.pca} performs a classical principal component analysis (PCA) using
#' \code{RcppArmadillo} package for faster and efficient computation.
#'
#' @param X an \eqn{(n\times p)} matrix whose rows are observations
#' and columns represent independent variables.
#' @param ndim an integer-valued target dimension.
#' @param cor mode of eigendecomposition. \code{FALSE} for decomposing covariance matrix,
#' and \code{TRUE} for correlation matrix.
#' @param preprocess an option for preprocessing the data. This supports three methods,
#' where default is \code{"center"}. See also \code{\link{aux.preprocess}} for more details.
#'
#' @return a named list containing
#' \describe{
#' \item{Y}{an \eqn{(n\times ndim)} matrix whose rows are embedded observations.}
#' \item{vars}{a vector containing variances of projected data onto principal components.}
#' \item{projection}{a \eqn{(p\times ndim)} whose columns are principal components.}
#' \item{trfinfo}{a list containing information for out-of-sample prediction.}
#' }
#'
#' @examples
#' ## use iris data
#' data(iris)
#' set.seed(100)
#' subid = sample(1:150,50)
#' X     = as.matrix(iris[subid,1:4])
#' lab   = as.factor(iris[subid,5])
#'
#' ## try different preprocessing procedure
#' out1 <- do.pca(X, ndim=2, preprocess="center")
#' out2 <- do.pca(X, ndim=2, preprocess="decorrelate")
#' out3 <- do.pca(X, ndim=2, preprocess="whiten")
#'
#' ## embeddings for each procedure
#' Y1 <- out1$Y; Y2 <- out2$Y; Y3 <- out3$Y
#'
#' ## visualize
#' opar <- par(no.readonly=TRUE)
#' par(mfrow=c(1,3))
#' plot(Y1, col=lab, pch=19, main="PCA::'center'")
#' plot(Y2, col=lab, pch=19, main="PCA::'decorrelate'")
#' plot(Y3, col=lab, pch=19, main="PCA::'whiten'")
#' par(opar)
#'
#' @author Kisung You
#' @references
#' \insertRef{pearson_liii_1901}{Rdimtools}
#'
#' @rdname linear_PCA
#' @concept linear_methods
#' @export
do.pca <- function(X,ndim=2,cor=FALSE,
                   preprocess=c("center","scale","cscale","decorrelate","whiten")){
  #------------------------------------------------------------------------
  # Preprocessing
  if (!is.matrix(X)){stop("* do.pca : 'X' should be a matrix.")}
  myndim = round(ndim)
  mycor  = as.logical(cor)
  myprep = ifelse(missing(preprocess), "center", match.arg(preprocess))

  #------------------------------------------------------------------------
  # Version 2 update
  output = dt_pca(X, myndim, myprep, mycor)
  output$vars = as.vector(output$vars)
  return(output)

  # # 1. typecheck is always first step to perform.
  # aux.typecheck(X)
  #
  # # 2. preprocessing
  # #   2-1. center,decorrelate, or whiten
  # if (missing(preprocess)){
  #   algpreprocess = "center"
  # } else {
  #   algpreprocess = match.arg(preprocess)
  # }
  # tmplist = aux.preprocess.hidden(X,type=algpreprocess,algtype="linear")
  # trfinfo = tmplist$info
  # pX      = tmplist$pX
  #
  # #   2-2. correlation or covariance matrix
  # if (cor){
  #   psdX = cor(pX)
  # } else if (cor==FALSE){
  #   psdX = cov(pX)
  # } else{
  #   stop("* do.pca : invalid 'cor' type. should be logical.")
  # }
  #
  # # 3. run method_pca
  # outeig  = base::eigen(psdX)
  # eigvals = outeig$values
  # eigvecs = aux.adjprojection(outeig$vectors)
  #
  #
  # # 4. branching
  # if (all(ndim=="auto")){
  #   varratio = 0.1
  #   if (!is.numeric(varratio)||(varratio>1)||(varratio<=0)){
  #     stop("* do.pca : 'varratio' should be in (0,1]")
  #   }
  #   tgtidx = as.integer(min(which((cumsum(eigvals)/sum(eigvals))>=varratio)))
  #   if (tgtidx<1){
  #     tgtidx = as.integer(1);
  #   }
  #   if (tgtidx>length(eigvals)){
  #     tgtidx = as.integer(length(eigvals))
  #   }
  # } else{
  #   if (!is.numeric(ndim)||(ndim<1)||(ndim>length(eigvals))||is.na(ndim)){
  #     stop("* do.pca : 'ndim' should be in [1,#(covariates)]")
  #   }
  #   tgtidx = as.integer(ndim)
  # }
  #
  # # 5. result
  # partials = (eigvecs[,1:tgtidx])
  # result = list()
  # result$Y          = (pX %*% partials)
  # result$vars       = eigvals[1:tgtidx]
  #
  # result$projection = partials
  # result$trfinfo    = trfinfo
  # return(result)
}



# call for later use ------------------------------------------------------
#' @keywords internal
pydo_pca <- function(myX, mydim, mycor, myproc){
  return(do.pca(myX, ndim=mydim, cor=mycor, preprocess = myproc))
}
