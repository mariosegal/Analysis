libname online 'C:\Documents and Settings\ewnym5s\My Documents\Online';
libname data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';


filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Online\Survey HHs.txt';
data online.survey_hhs;
length survey_ID $ 8 hhid $ 9;
infile myfile dlm='09'x dsd firstobs=2 lrecl=4096;
input survey_id $  hhid $;
run;


proc sort data=online.survey_hhs;
by hhid;
run;

data online.survey_hhs_matched;
merge online.survey_hhs (in=a) data.main_201111 (in=b);
by hhid;
if a and b;
run;

data online.survey_hhs_missing;
merge online.survey_hhs (in=a) data.main_201111 (in=b);
by hhid;
if a and not b;
keep survey_id hhid;
run;



libname bbseg 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

data online.survey_hhs_matched_bus;
merge online.survey_hhs_missing(in=a) bbseg.hhdata_new  (in=b);
by hhid;
if a and b;
run;
