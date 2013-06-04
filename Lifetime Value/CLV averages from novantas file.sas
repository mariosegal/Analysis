proc fslist fileref='C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value\CLV_FINAL_2012Q3_20121205.csv'; run;

filename clvdata  'C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value\CLV_FINAL_2012Q3_20121205.csv';

data clv_data;
infile clvdata dlm=',' dsd missover lrecl=4096 firstobs=2;
input HH_ID CLV_TOTAL CLV_FWD EXP_REM_TENURE_YRS MAT_FLAG POST_DT_FL MIN_SEG;
run;


proc tabulate data=clv_data missing;
class mat_flag min_seg;
var clv_total;
table min_seg all, mat_flag*(N*f=comma12. clv_total*sum*f=dollar24.) / nocellmerge misstext='0';
format min_seg segfmt.;
run;
