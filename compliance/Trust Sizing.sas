libname fdic 'C:\Documents and Settings\ewnym5s\My Documents\Compliance';


data fdic_test;
length title1 $ 50 title2 $ 40 title3 $ 40 title4 $ 40 ptype $ 3 stype $ 3 rel_code $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\fdic.txt' dsd dlm='09'x missover lrecl=4096 firstobs=2 obs=max;
input  hhid acct ssn1 ssn2 balance title1 $ title2 $ title3 $ title4 $ ptype $ stype $ rel_code $;
run;

options compress=yes;
%squeeze(fdic_test, fdic.Data_201209)


Data fdic.Data_201209;
set fdic.Data_201209 (obs=max);
array words{14} $ 16 _temporary_  ('payable on death' 'POD' 'ITF' 'in trust for' 'as trustee for' 'ATF' 'living trust' 'family trust' 
                                    'Trust' 'Trustee' ' Trusts' 'Trustees' 'Death' 'TOTTEN');


tag=0;

do i=1 to 14;	
	if find(catx(" ",title1,title2,title3,title4),words{i},'it') then tag+1;
end;

flag=0;
if rel_code in ('TR1','TRF','TRU') then flag = 1;
drop i;
run;

proc tabulate data=fdic.Data_201209 missing;
class flag tag;
var balance;
table Tag='Word Matches' ALL , (flag='Trust Code')*(N='Accts'*f=comma12. Balance*sum*f=comma18.) / nocellmerge;
format flag binary_flag.;
run;

proc tabulate data=fdic.Data_201209 missing;
where tag ge 1 or flag eq 1;
class ptype;
var balance;
table PTYPE ALL, (N='Accts'*f=comma12. Balance*sum*f=comma18.) / nocellmerge;
format flag binary_flag.;
run;


