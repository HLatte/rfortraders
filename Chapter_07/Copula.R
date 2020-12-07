# Copula
# https://firsttimeprogrammer.blogspot.com/2016/03/how-to-fit-copula-model-in-r-heavily.html

# Copula package
library(copula)
# Fancy 3D plain scatterplots
library(scatterplot3d)
# ggplot2
library(ggplot2)
# Useful package to set ggplot plots one next to the other
library(grid)
set.seed(235)

# Generate a bivariate normal copula with rho = 0.7
normal <- normalCopula(param = 0.7, dim = 2)
# Generate a bivariate t-copula with rho = 0.8 and df = 2
stc <- tCopula(param = 0.8, dim = 2, df = 2)

# Build a Frank, a Gumbel and a Clayton copula
frank <- frankCopula(dim = 2, param = 8)
gumbel <- gumbelCopula(dim = 3, param = 5.6)
clayton <- claytonCopula(dim = 4, param = 19)

# Print information on the Frank copula
print(frank)



# Select the copula
cp <- claytonCopula(param = c(3.4), dim = 2)

# Generate the multivariate distribution (in this case it is just bivariate) with normal and t marginals
multivariate_dist <- mvdc(copula = cp,
                          margins = c("norm", "t"),
                          paramMargins = list(list(mean = 2, sd=3),
                                              list(df = 2)) )

print(multivariate_dist)



# Generate the normal copula and sample some observations
coef_ <- 0.8
mycopula <- normalCopula(coef_, dim = 2)
u <- rCopula(2000, mycopula)

# Compute the density
pdf_ <- dCopula(u, mycopula)

# Compute the CDF
cdf <- pCopula(u, mycopula)

# Generate random sample observations from the multivariate distribution
v <- rMvdc(2000, multivariate_dist)

# Compute the density
pdf_mvd <- dMvdc(v, multivariate_dist)

# Compute the CDF
cdf_mvd <- pMvdc(v, multivariate_dist)


