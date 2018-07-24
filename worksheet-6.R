# Linear models

... <- read.csv(...,
  na.strings = '')
fit <- ...(
  ...,
  ...)

# Metadata matters

fit <- lm(
  ...,
  data = animals)

# GLM families

fit <- ...(...,
  ...,
  data = animals)

# Logistic regression

animals$sex <- ...(...)
fit <- glm(...,
  ...,
  data = animals)

# Random intercept

library(...)
fit <- ...(
  ...,
  data = animals)

# Random slope

fit <- lmer(
  hindfoot_length ~ 
    ...,
  data = animals)

# RStan

library(dplyr)
stanimals <- animals %>%
  select(...) %>%
  na.omit() %>%
  mutate(
    log_weight = log(weight),
    species_id = ...) %>%
  select(-weight)
stanimals <- c(
  N = ...,
  M = ...,
  ...)

library(rstan)
samp <- stan(file = ...,
             data = ...,
             iter = ...)
saveRDS(samp, 'stanimals.RDS')

## Pre-compiled Stan

library(rstanarm)
fit <- ...(
  ...,
  data = animals,
  ...)