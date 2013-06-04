proc sql;
select count(*) as total from hudson.hudson_hh;
select count(*) as business from hudson.hudson_hh where products eq . or products eq 0;
select count(*) as external from hudson.hudson_hh where not(products eq . or products eq 0) and products eq 1 and mtx1 eq 1;
select count(*) as analyzed from hudson.hudson_hh where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1);
quit;

proc freq data=hudson.hudson_hh;
where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1);
table bta_group*active;
format bta_group $bta_a.;
run;


proc freq data=hudson.hudson_hh ;
where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1);
table state*bta_group / missing;
format bta_group $bta_a.;
run;

select bta_group format $bta_a.,count(*) format comma12. as analyzed from hudson.hudson_hh where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1) 
       group by bta_group format $bta_a.;
quit;



