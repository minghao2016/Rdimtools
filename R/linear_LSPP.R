#' Local Similarity Preserving Projection
#'
#' Local Similarity Preserving Projection (LSPP) is a variant of LPP in that
#' it employs a sample-dependent graph generation process as of \code{\link{do.sdlpp}}.
#' LSPP takes advantage of labeling information to correct local similarity weight
#' in order to make intra-class weight larger than inter-class weight. It uses
#' PCA preprocessing as suggested from the original work.
#'
#' @param X an \eqn{(n\times p)} matrix or data frame whose rows are observations.
#' @param label a length-\eqn{n} vector of data class labels.
#' @param ndim an integer-valued target dimension.
#' @param t kernel bandwidth in \eqn{(0,\infty)}.
#' @param preprocess  an additional option for preprocessing the data.
#' Default is "center". See also \code{\link{aux.preprocess}} for more details.
#'
#' @return a named list containing
#' \describe{
#' \item{Y}{an \eqn{(n\times ndim)} matrix whose rows are embedded observations.}
#' \item{trfinfo}{a list containing information for out-of-sample prediction.}
#' \item{projection}{a \eqn{(p\times ndim)} whose columns are basis for projection.}
#' }
#'
#' @examples
#' ## generate data of 2 types with clear difference
#' diff = 15
#' dt1  = aux.gensamples(n=50)-diff;
#' dt2  = aux.gensamples(n=50)+diff;
#'
#' ## merge the data and create a label correspondingly
#' Y      = rbind(dt1,dt2)
#' label  = rep(1:2, each=50)
#'
#' ## compare with PCA
#' out1 <- do.pca(Y, ndim=2)
#' out2 <- do.slpp(Y, label, ndim=2)
#'
#' ## visualize
#' opar <- par(no.readonly=TRUE)
#' par(mfrow=c(1,2))
#' plot(out1$Y, col=label, pch=19, main="PCA")
#' plot(out2$Y, col=label, pch=19, main="LSPP")
#' par(opar)
#'
#' @references
#' \insertRef{huang_local_2015}{Rdimtools}
#'
#' @seealso \code{\link{do.sdlpp}}, \code{\link{do.lpp}}
#' @rdname linear_LSPP
#' @author Kisung You
#' @concept linear_methods
#' @export
do.lspp <- function(X, label, ndim=2, t=1.0,
                    preprocess=c("center","scale","cscale","decorrelate","whiten")){
  #------------------------------------------------------------------------
  ## PREPROCESSING
  #   1. data matrix
  aux.typecheck(X)
  n = nrow(X)
  p = ncol(X)
  #   2. label : check and return a de-factored vector
  #   For this example, there should be no degenerate class of size 1.
  label  = check_label(label, n)
  ulabel = unique(label)
  for (i in 1:length(ulabel)){
    if (sum(label==ulabel[i])==1){
      stop("* do.lspp : no degerate class of size 1 is allowed.")
    }
  }
  if (any(is.na(label))||(any(is.infinite(label)))){stop("* Supervised Learning : any element of 'label' as NA or Inf will simply be considered as a class, not missing entries.")  }
  #   3. ndim
  ndim = as.integer(ndim)
  if (!check_ndim(ndim,p)){stop("* do.lspp : 'ndim' is a positive integer in [1,#(covariates)).")}
  #   4. t
  t = as.double(t)
  if (!check_NumMM(t,0,1e+10,compact=FALSE)){stop("* do.lspp : 't' should be a positive real number.")}
  #   5. preprocess
  if (missing(preprocess)){    algpreprocess = "center"  }
  else {    algpreprocess = match.arg(preprocess)  }

  #------------------------------------------------------------------------
  ## PART 1 : Pre-LSPP process
  #   1. data preprocessing
  tmplist = aux.preprocess.hidden(X,type=algpreprocess,algtype="linear")
  trfinfo = tmplist$info
  pX      = tmplist$pX

  #   2. PCA preprocessing : refer to SLPP
  eigtest = eigen(cov(pX), only.values=TRUE)
  pcadim  = sum(eigtest$values > 0)
  if (pcadim <= ndim){
    warning("* do.lspp : target 'ndim' is larger than intrinsic data dimension achieved from PCA.")
    projection_first = diag(p)
    pcapX = pX
  } else{
    projection_first = aux.adjprojection(eigen(cov(pX))$vectors[,1:pcadim])
    pcapX = pX%*%projection_first
  }

  #------------------------------------------------------------------------
  ## PART 2 : Main LSPP Code
  #   1. prelim : D : normalized square distance
  D = (as.matrix(dist(pcapX, method="euclidean"))^2)
  for (i in 1:n){
    sumvecD = sum(D[i,])
    D[i,] = D[i,]/sumvecD
  }
  #   2. prelim : S : similarity weight
  S = exp(-D/(2*(t^2)))
  for (i in 1:n){
    xi = as.vector(pcapX[i,])
    for (j in (i+1):n){
      xj = as.vector(pcapX[j,])
      if (label[i]!=label[j]){
        etanumerator = sum(xi*xj)
        etadenom     = sqrt(sum(xi*xi))*sqrt(sum(xj*xj))
        eta           = etanumerator/etadenom
        S[i,j] = S[i,j]*eta
        S[j,i] = S[j,i]*eta
      }
    }
  }
  #   3. prelim : svec : the term to be compared
  svec = rep(0,n)
  for (i in 1:n){
    colidx = setdiff(which(label==label[i]),i)  # removing oneself
    svec[i] = sum(S[i,colidx])/(length(colidx)) # oneself is already removed !
  }
  #   4. adjacency matrix
  Ws = method_lspp_computeW(S,svec)
  #   5. symmetrized computation
  Wtilde = Ws+t(Ws)
  Ds = diag(rowSums(Ws))+diag(colSums(Ws))
  Ls = Ds-Wtilde
  #   6. projection : borrowed from SLPP : lowest ones
  LHS = (t(pcapX)%*%Ls%*%pcapX)
  RHS = (t(pcapX)%*%Ds%*%pcapX)
  projection_second = aux.geigen(LHS, RHS, ndim, maximal=FALSE)


  #------------------------------------------------------------------------
  ## RETURN
  #   1. all projection
  projection = (projection_first%*%projection_second)
  #   2. return output
  result = list()
  result$Y = pX%*%projection
  result$trfinfo = trfinfo
  result$projection = projection
  return(result)

}
