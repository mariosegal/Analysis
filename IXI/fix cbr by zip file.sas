proc freq data=IXi.CBR_BY_ZIP_2012;
table cbr;
run;


data IXi.CBR_BY_ZIP_2012;
length cbr_num 8;
set IXi.CBR_BY_ZIP_2012;
select (strip(cbr));
	when ('13') cbr_num = 14;
	when ('14') cbr_num=13;
	when ('New Jers') cbr_num = 99;
	when ('Central') cbr_num = 99;
	otherwise cbr_num = cbr;
end;
run;


ods html style=htmlblue;
legend1 label=("CBR" font="swiss/bold");
proc gmap map=sas.us_zips (where=(state in ("NY","DE","MD","WV","VA","DC","PA")) ) 
          data=IXi.CBR_BY_ZIP_2012 (rename=(zip=zip_char) where=(cbr_num ne 99));
id zip_char;
choro cbr_num / discrete statistic=mean coutline=same legend=legend1;

format cbr_num cbr2012fmt.;
run;
quit;

proc datasets library=sas;
modify Us_zips;
	rename zcta5ce10 = zip_char;
run;


 		
