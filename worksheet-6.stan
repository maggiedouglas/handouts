data {
  int N;
  int M;
  vector[N] hindfoot_length;
  int species_id[N];
  vector[N] log_weight;
}
parameters {
  real beta0;
  vector[M] beta1;
  real beta2;
  real<lower=0> sigma0;
  real<lower=0> sigma1;
}
//transformed parameters {
//  vector[N] mu;
//  mu = beta0 + beta1[species_idx] + log_weight * beta2;
//}
model {
  vector[N] mu;

  mu = beta0 + beta1[species_id] + beta2 * log_weight;
  hindfoot_length ~ normal(mu, sigma0);
  beta1 ~ normal(0, sigma1);

  beta0 ~ normal(0, 5);
  beta2 ~ normal(0, 5);
  sigma0 ~ cauchy(0, 5);
  sigma1 ~ cauchy(0, 5);
}
