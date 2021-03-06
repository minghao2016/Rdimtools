#' Dimension Reduction and Estimation Methods
#'
#' \pkg{Rdimtools} is an R suite of a number of dimension reduction and estimation methods
#' implemented using \pkg{RcppArmadillo} for efficient computations. Please see the reference
#' from the \href{http://kyoustat.com/Rdimtools/}{package webpage}.
#'
#' @docType package
#' @name package-Rdimtools
#' @aliases Rdimtools-package
#' @import Rcsdp
#' @import Rdpack
#' @import CVXR
#' @import RcppDE
#' @import maotai
#' @importFrom mclustcomp mclustcomp
#' @importFrom utils packageVersion combn getFromNamespace
#' @importFrom RSpectra eigs svds
#' @importFrom stats dist cov rnorm runif kmeans cor var sd approx lm coef coefficients as.dist hclust cutree quantile median integrate optimize
#' @importFrom graphics par image plot hist
#' @importFrom Rcpp evalCpp
#' @useDynLib Rdimtools, .registration=TRUE
NULL

# NOTES
# 1. reference travis builder : https://github.com/mlr-org/mlr/blob/master/.travis.yml
