data s2;
set bb.bbmain_201212;

if contrib1 <810.075 then do;
if baloc_con <296.92 then do;
if sign_ons <24.5 then do;
if dda_amt <7185.13 then do;
if dda_con <51.615 then do;
if br_tran_amt <2901.07 then do;
s2 = 'No';
end;
if br_tran_amt >2901.07 then do;
s2 = 'No';
end;
end;
if dda_con >51.615 then do;
s2 = 'Yes';
end;
end;
if dda_amt >7185.13 then do;
if checks <46 then do;
if chkpd <0.5 then do;
s2 = 'No';
end;
if chkpd >0.5 then do;
s2 = 'No';
end;
end;
if checks >46 then do;
if sign_ons <1.5 then do;
s2 = 'No';
end;
if sign_ons >1.5 then do;
if contrib1 <163.875 then do;
s2 = 'No';
end;
if contrib1 >163.875 then do;
if rm <0.5 then do;
s2 = 'Yes';
end;
if rm >0.5 then do;
if sign_ons <11.5 then do;
if sign_ons <7.5 then do;
if deptkt <8 then do;
s2 = 'No';
end;
if deptkt >8 then do;
s2 = 'No';
end;
end;
if sign_ons >7.5 then do;
s2 = 'Yes';
end;
end;
if sign_ons >11.5 then do;
if dda_amt <55382.6 then do;
s2 = 'No';
end;
if dda_amt >55382.6 then do;
s2 = 'No';
end;
end;
end;
end;
end;
end;
end;
end;
if sign_ons >24.5 then do;
if vpos_num <4.5 then do;
if tenure <5968 then do;
if dda_amt <171697 then do;
s2 = 'Yes';
end;
if dda_amt >171697 then do;
s2 = 'No';
end;
end;
if tenure >5968 then do;
if cln_amt <28958.4 then do;
s2 = 'No';
end;
if cln_amt >28958.4 then do;
s2 = 'No';
end;
end;
end;
if vpos_num >4.5 then do;
s2 = 'No';
end;
end;
end;
if baloc_con >296.92 then do;
s2 = 'No';
end;
end;
if contrib1 >810.075 then do;
if contrib1 <839.495 then do;
s2 = 'Yes';
end;
if contrib1 >839.495 then do;
if cb_dist <0.31 then do;
s2 = 'No';
end;
if cb_dist >0.31 then do;
if ach <55.5 then do;
if mms_amt <24084.1 then do;
if dda_amt <116596 then do;
if baloc_amt <98990.6 then do;
s2 = 'No';
end;
if baloc_amt >98990.6 then do;
s2 = 'No';
end;
end;
if dda_amt >116596 then do;
if baloc_con <-1.375 then do;
s2 = 'No';
end;
if baloc_con >-1.375 then do;
s2 = 'Yes';
end;
end;
end;
if mms_amt >24084.1 then do;
if dda_amt <772924 then do;
s2 = 'No';
end;
if dda_amt >772924 then do;
s2 = 'No';
end;
end;
end;
if ach >55.5 then do;
if dda_amt <435515 then do;
s2 = 'Yes';
end;
if dda_amt >435515 then do;
s2 = 'Yes';
end;
end;
end;
end;
end;


keep s2 hhid;
run;