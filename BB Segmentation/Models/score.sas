data combined;
merge s1 (in=a) s2(in=b) s3(in=c) s4(in=d) s5(in=e) s6(in=f);
by hhid;
if a and b and c and d and e and f;
select (substr(s1,1,1));
	when('Y') s1="1";
	otherwise s1="0";
end;
select (substr(s2,1,1));
	when('Y') s2="1";
	otherwise s2="0";
end;
select (substr(s3,1,1));
	when('Y') s3="1";
	otherwise s3="0";
end;
select (substr(s4,1,1));
	when('Y') s4="1";
	otherwise s4="0";
end;
select (substr(s5,1,1));
	when('Y') s5="1";
	otherwise s5="0";
end;
select (substr(s6,1,1));
	when('Y') s6="1";
	otherwise s6="0";
end;
run;

data combined;
set combined;
count=sum(of s:);
predict = 0;
*tie breakers;
if count eq 2 then do;
	if s1 eq "1" and s2 eq "1" then predict=1;
	if s1 eq "1" and s4 eq "1" then predict=1;
	if s1 eq "1" and s6 eq "1" then predict=1;
	if s2 eq "1" and s4 eq "1" then predict=2;
	if s2 eq "1" and s6 eq "1" then predict=6;
	if s4 eq "1" and s5 eq "1" then predict=5;
end;
*assign simple;
if count eq 1 the do;
	if s1 eq "1" then predict=1;
	if s2 eq "1" then predict=2;
	if s3 eq "1" then predict=3;
	if s4 eq "1" then predict=4;
	if s5 eq "1" then predict=5;
	if s6 eq "1" then predict=6;
end;
*if 3 or more, really choose at random, take first;
if count ge 3 the do;
	if s1 eq "1" then predict=1;
	else if s2 eq "1" then predict=2;
	else if s3 eq "1" then predict=3;
	else if s4 eq "1" then predict=4;
	else if s5 eq "1" then predict=5;
	else if s6 eq "1" then predict=6;
end;
run;


proc freq data=combined;
table predict*count / nopercent norow nocol;
run;


proc freq data=s6;
table s6;
run;

*do profile;
data bb.bbmain_201212 (compress=binary);
merge bb.bbmain_201212 (in=left) combined (in=right keep=hhid predict rename=(predict=bbseg));
by hhid;
hh=1;
if left;
run;

proc format library=sas;
value bbseg (notsorted)
            1 = 'Simple & Stable'
			2 = 'Succesful and Service Dependent'
			3 = 'Stable Under-served'
			4 = 'Content and Well served'
			5 = 'Complex and Extended management'
			6 = 'Sophisticated and Demanding'
			0 = 'Not Coded';
run;


proc tabulate data=bb.bbmain_201212 order=data;
class bbseg /preloadfmt;
var dda: mms: sav: tda: mtg: cln: cls: baloc: boloc: heqb: hh
    vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd 
    ACH rcd_num winfo_num lckbox top40 RM cb_dist cv0 cr6 com_dda br_tran_num br_tran_amt vru_num nsf chks_dep cash_mgmt wire_in wire_out  ;
table bbseg='BB Segment' all, N='HHs'*(hh dda mms sav tda mtg cln cls baloc boloc heqb)*f=comma12. / nocellmerge misstext='0';
table bbseg='BB Segment' all, rowpctsum<hh>='Penetration'*(dda mms sav tda mtg cln cls baloc boloc heqb)*f=pctfmt. / nocellmerge misstext='0%';
table bbseg='BB Segment' all, (dda_amt*rowpctsum<dda> mms_amt*rowpctsum<mms> sav_amt*rowpctsum<sav> tda_amt*rowpctsum<tda> mtg_amt*rowpctsum<mtg> 
                cln_amt*rowpctsum<cln> cls_amt*rowpctsum<cls> baloc_amt*rowpctsum<baloc> boloc_amt*rowpctsum<boloc> heqb_amt*rowpctsum<heqb>)*f=pctdoll. / nocellmerge misstext='$0';
table bbseg='BB Segment' all, rowpctsum<hh>*(vpos_num  mpos_num deptkt curdep_num chkpd ACH rcd_num br_tran_num chks_dep wire_in wire_out)*f=pctcomma. / nocellmerge misstext='0.0';
format bbseg bbseg.;
run;

      

