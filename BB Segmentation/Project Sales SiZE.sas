/* Create $1-$10 Million Universe for Non-Matched Customers using: *** bus.full_data2_info1_merge_no_sum */
/* Based on PROC UNIVARIATE for Non-Matched, use  25% Percentile for Bal and Net_Contrib_YTD as Cut-off Threshold */
/* Use max value for Matched Group as max value for Non-Matched Group */

data work.temp3;


data work.temp4;
  set work.temp3;

  where (11211.34<=sum_sum_prime_bal<=9410989.48) and (430.84<=sum_sum_contr_net_ytd<=159146.92);

  if 430.84<=sum_sum_contr_net_ytd<6000 then sales_group='03b - $1 million to $3 million';
  else if 6000<=sum_sum_contr_net_ytd<15000 then sales_group='04b - $4 million to $6 million';
  else if 15000<=sum_sum_contr_net_ytd<=159146.92 then sales_group='05b - $7 million to $10 million';
  else sales_group='06b - gt $10 million';
run;
