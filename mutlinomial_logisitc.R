library(ggplot2)
library(reshape2)
library(foreign)
library(nnet)


#http://www.ats.ucla.edu/stat/r/dae/mlogit.htm

ml <- read.dta("http://www.ats.ucla.edu/stat/data/hsbdemo.dta")

with(ml, table(ses, prog))
with(ml, do.call(rbind, tapply(write, prog,
    function(x) c(M = mean(x), SD = sd(x)))))

ml$prog2 <- relevel(ml$prog, ref = "academic")
test <- multinom(prog2 ~ ses + write, data = ml)
summary(test)
# two tailed z test
z <- summary(test)$coefficients / summary(test)$standard.errors
(1 - pnorm(abs(z), 0, 1)) * 2

# log odds exponentiated 
exp(coef(test))

# predicted probs
head(pp <- fitted(test))
dwrite <- data.frame(ses = rep(c("low", "middle", "high"), each = 41), write = rep(c(30:70),
                                                                                   3))
## store the predicted probabilities for each value of ses and write
pp.write <- cbind(dwrite, predict(test, newdata = dwrite, type = "probs", se = TRUE))

## calculate the mean probabilities within each level of ses
by(pp.write[, 3:5], pp.write$ses, colMeans)

## melt data set to long for ggplot2
lpp <- melt(pp.write, id.vars = c("ses", "write"), value.name = "probability")
head(lpp)  # view first few rows

## plot predicted probabilities across write values for each level of ses
## facetted by program type
ggplot(lpp, aes( x = write, y = probability, colour = ses)) +
  geom_line() + facet_grid(variable ~., scales = "free" )


