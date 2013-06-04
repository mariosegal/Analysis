filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\tran_segm.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

options compress=no;
%create_report(class1 = tran_code, fmt1 = $transegm,out_dir = C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled, main_source = data.main_201303,
                contrib_source = data.contrib_201303, condition = tran_code ne '',out_file=tran_segm_profile_201303b,
                logo_file=C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png)


