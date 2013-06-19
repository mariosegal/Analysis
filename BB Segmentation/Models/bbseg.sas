data bbseg;
set bb.bbmain_201212;

	if svcs <3.5 then do;
	if deptkt <10 then do;
	if dda_con <52.515 then do;
	if dda_con <28.62 then do;
	bbseg = 'Content & Well Served';
	end;
	if dda_con >28.62 then do;
	bbseg = 'Simple & Stable';
	end;
	end;
	if dda_con >52.515 then do;
	bbseg = 'Simple & Stable';
	end;
	end;
	if deptkt >10 then do;
	if ach <71 then do;
	if br_tran_num <28.5 then do;
	bbseg = 'Stable 
	Underserved';
	end;
	if br_tran_num >28.5 then do;
	bbseg = 'Simple & Stable';
	end;
	end;
	if ach >71 then do;
	bbseg = 'Stable 
	Underserved';
	end;
	end;
	end;
	if svcs >3.5 then do;
	if curdep_amt <6534 then do;
	if dda_amt <162845 then do;
	if cln_amt <301989 then do;
	if br_tran_num <7.5 then do;
	if dda_amt <34712.3 then do;
	if chkpd <13.5 then do;
	bbseg = 'Successful Service-Dependent';
	end;
	if chkpd >13.5 then do;
	bbseg = 'Simple & Stable';
	end;
	end;
	if dda_amt >34712.3 then do;
	if sav_amt <480.175 then do;
	bbseg = 'Simple & Stable';
	end;
	if sav_amt >480.175 then do;
	bbseg = 'Sophisticated & Demanding';
	end;
	end;
	end;
	if br_tran_num >7.5 then do;
	if checks <52 then do;
	if curdep_num <0.5 then do;
	bbseg = 'Simple & Stable';
	end;
	if curdep_num >0.5 then do;
	bbseg = 'Complex & Extended Mgmt.';
	end;
	end;
	if checks >52 then do;
	if cb_dist <0.435 then do;
	bbseg = 'Stable 
	Underserved';
	end;
	if cb_dist >0.435 then do;
	if dda_amt <69408.8 then do;
	bbseg = 'Content & Well Served';
	end;
	if dda_amt >69408.8 then do;
	if dda_amt <117532 then do;
	bbseg = 'Complex & Extended Mgmt.';
	end;
	if dda_amt >117532 then do;
	bbseg = 'Successful Service-Dependent';
	end;
	end;
	end;
	end;
	end;
	end;
	if cln_amt >301989 then do;
	if sav_amt <539.7 then do;
	bbseg = 'Sophisticated & Demanding';
	end;
	if sav_amt >539.7 then do;
	bbseg = 'Content & Well Served';
	end;
	end;
	end;
	if dda_amt >162845 then do;
	if contrib1 <597.99 then do;
	bbseg = 'Sophisticated & Demanding';
	end;
	if contrib1 >597.99 then do;
	if sav_con <1.775 then do;
	if br_tran_amt <64877.8 then do;
	bbseg = 'Successful Service-Dependent';
	end;
	if br_tran_amt >64877.8 then do;
	bbseg = 'Content & Well Served';
	end;
	end;
	if sav_con >1.775 then do;
	bbseg = 'Successful Service-Dependent';
	end;
	end;
	end;
	end;
	if curdep_amt >6534 then do;
	if X_1_to_2mm <0.5 then do;
	if sign_ons <12 then do;
	bbseg = 'Content & Well Served';
	end;
	if sign_ons >12 then do;
	bbseg = 'Content & Well Served';
	end;
	end;
	if X_1_to_2mm >0.5 then do;
	if tenure <2753.5 then do;
	bbseg = 'Complex & Extended Mgmt.';
	end;
	if tenure >2753.5 then do;
	bbseg = 'Simple & Stable';
	end;
	end;
	end;
	end;

	keep bbseg hhid;
	run;
