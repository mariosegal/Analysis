proc tabulate data=wip.temp_demog out=wip.child1(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  (children ),(FLAG_UNDER_10 );

run;

proc transpose data=wip.child1 out = wip.child2 label=under10;
by children;
ID flag_under_10;
run;

data wip.child3;
set wip.child2 (rename=(Y=under10_Y N=under10_N));
drop _NAME_;
run;



proc tabulate data=wip.temp_demog out=wip.child4(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  (children ),(flag_11_15 );
run;

proc transpose data=wip.child4 out = wip.child5 label=under10;
by children;
ID flag_11_15;
run;

data wip.child6;
set wip.child5 (rename=(Y=_11_15_Y N=_11_15_N));
drop _NAME_;
run;

proc tabulate data=wip.temp_demog out=wip.child7(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  (children ),(flag_16_17 );
run;

proc transpose data=wip.child7 out = wip.child8 label=under10;
by children;
ID flag_16_17;
run;

data wip.child9;
set wip.child8 (rename=(Y=_16_17_Y N=_16_17_N));
drop _NAME_;
run;

proc tabulate data=wip.temp_demog out=wip.child(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  (children *HH);
run;

data wip.child10;
merge wip.child (in=a) wip.child3 wip.child6 wip.child9;
by children;
run;

data wip.child11;
set wip.child10;
array data{7} HH_sum under10_y under10_n _11_15_y _11_15_n _16_17_y _16_17_n;
array Y{7} _temporary_;
array N{7} _temporary_;

if children='Y' then do;
	do i = 1 to 7 ;
		Y{i} = data{i};
	end;

end;
else if children='N' then do;
	do i = 1 to 7 ;
		N{i} = data{i};
	end;
	return;
end;

if _N_ = 2 then do;
	Grp = 'Overall Presence';
	val = 'Y';
	HH = Y{1};
	output;
	Grp = 'Overall Presence';
	val = 'N';
	HH = N{1};
	output;

	Grp = 'Under10';
	val = 'Y';
	HH = sum(Y{2},N{2});
	output;
	Grp = 'Under10';
	val = 'N';
	HH = sum(Y{3},N{3});
	output;

	Grp = '11 to 15';
	val = 'Y';
	HH = sum(Y{4},N{4});
	output;
	Grp = '11 to 15';
	val = 'N';
	HH = sum(Y{5},N{5});
	output;

	Grp = '16 to 17';
	val = 'Y';
	HH = sum(Y{6},N{6});
	output;
	Grp = '16 to 17';
	val = 'N';
	HH = sum(Y{7},N{7});
	output;
end;

drop i children hh_sum under10_n under10_y _11_15_n _11_15_y _16_17_y _16_17_n;
run;
