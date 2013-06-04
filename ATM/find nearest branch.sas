*create a view of the ATM dataset;
proc sort data= atm.atm_coords;
by y1 x1;
run;

data atm_view / view=atm_view;
set atm.atm_coords( where=(Import_Export_ID ne '' and (x1 ne . or y1 ne .)));
rename Import_Export_ID=wsid1 x1=x2 y1=y2;
keep Import_Export_ID x1 y1;
run;

*define a function to calculate the grand radius distance approximation;

proc fcmp outlib=work.functions.mario;
function dist(x1,y1,x2,y2);
	return (3949.99 * arcos(sin(Y1) * sin(Y2) + cos(Y1) * cos(Y2) * cos(X1 - X2)));
endsub;
run;
quit;


data test;
retain m n;
length error_code $ 10 best_id $ 8;
*define the variables for hash objects, line only executes at compilation;
if 0 then set atm_view ;
*at beginning of execution, load atm_view into hash and also define the iterator;
if _N_ eq 1 then do;
	dcl hash h(dataset: "atm_view",ordered:'a');
	h.definekey('x2','y2');
	h.definedata(all: 'yes');
	h.definedone();
    
	dcl hiter hi('h');
end;
m=20;
*load the atm_data to find the nearest atm and calculate the distance;
set atm.atm_coords (where=(wsid ne '' and (x1 ne . or y1 ne .)) rename= (import_export_id = wsid) firstobs=15  );
n=_n_;

rc=hi.setcur(key: x1,key: y1);
if rc = 0 then do; *there was a match;
	*since dataset is ordered by lat/long the closest one is among the few before or after, it is I guess the one;
    *where euclidean distance is smallest, it is not necessarilly prev or next as it the distance depends on 2 coordinates;
	*I will go back 5 and then go up to 5 after;
	do q = 1 to m;
		rc1=hi.prev();
		if rc1 ne 0 then q=10; *do not go back more if you got an error rc1, you must be at first one already;
	end;
	best = 999999; *initialize best distance to a ridiculous value;
	best_id=''; *initialize if of best match;
	do p = 1 to (m*2+1); *since i do not coutn the current, I need 1 more;
		*you will find the same one so do not calculate the distance then;
		if wsid ne wsid1 then do;
			current = geodist(y1,x1,y2,x2);
			if current lt best then do;
	        	best = current; 
				best_id = wsid1;
			end;
		end;
		else current=.; *this is the distance to itself, really zero, call it . to differentiate;
			
		rc2=hi.next();
		if rc2 ne 0 then p = 15; *if you can't move forward you must be at then end, so stop;
		output; *so I can see if it works;
	end;
end;
if rc ne 0 then do; *this is not expected, as the 2 datasets are the same, but good practice;
	error_code = 'not found';
	call missing (x2, y2, best, current);
end;

keep n x1 y1 best best_id wsid p rc1 x2 y2 wsid1 current q ;
run;

*requires sort by y1 x1, if reversed change key order and find();
data test1;
retain m n;
length error_code $ 10 best_id $ 8;
*define the variables for hash objects, line only executes at compilation;
if 0 then set atm_view ;
*at beginning of execution, load atm_view into hash and also define the iterator;
if _N_ eq 1 then do;
	dcl hash h(dataset: "atm_view",ordered:'a');
	h.definekey('y2','x2');
	h.definedata(all: 'yes');
	h.definedone();
    
	dcl hiter hi('h');
end;
m=20;
*load the atm_data to find the nearest atm and calculate the distance;
set atm.atm_coords (where=(wsid ne '' and (x1 ne . or y1 ne .)) rename= (import_export_id = wsid) firstobs=15  );
n=_n_;


best = 999999; *initialize best distance to a ridiculous value;
best_id=''; *initialize if of best match;

rc=hi.setcur(key: y1,key: x1);
if rc = 0 then do; *there was a match;
	*since dataset is ordered by lat/long the closest one is among the few before or after, it is I guess the one;
    *where euclidean distance is smallest, it is not necessarilly prev or next as it the distance depends on 2 coordinates;
	*I will go back 5 and then go up to 5 after;
    
	do q = -1 to -m by -1;
		rc1=hi.prev();
		if rc1 ne 0 then do;
			q=-m-1; *do not go back more if you got an error rc1, you must be at first one already;
			call missing (x2, y2, current);
	    end;
		else do;
			current = geodist(y1,x1,y2,x2);
			if current lt best and current ne . then do;
	        	best = current; 
				best_id = wsid1;
			end;
		end;
		output ; *for validation purposes;
	end;

	*search forwards;
	rc=hi.setcur(key: y1,key:x1);
	do q = 1 to m by 1; 
		rc2=hi.next();
        if rc2 ne 0 then do;
			q=m+1; *do not go forward more if you got an error rc2, you must be at end;
			call missing (x2, y2, current);
	    end;
		else do;
			current = geodist(y1,x1,y2,x2);
			if current lt best and current ne . then do;
	        	best = current; 
				best_id = wsid1;
			end;
		end;
		output ; *for validation purposes;
	end;
end;

if rc ne 0 then do; *this is not expected, as the 2 datasets are the same, but good practice;
	error_code = 'not found';
	call missing (x2, y2, best, current);
end;

keep n x1 y1 best best_id wsid rc1 x2 y2 wsid1 current q ;
run;

*his is the winner, so far - at least I do the iteration in memory;
*one idea to improve is to stop looking after best is < 1 mile;

data atm.closest_atms;
retain m n;
length error_code $ 10 best_id $ 8;
*define the variables for hash objects, line only executes at compilation;
if 0 then set atm_view ;
*at beginning of execution, load atm_view into hash and also define the iterator;
if _N_ eq 1 then do;
	dcl hash h(dataset: "atm_view",ordered:'a');
	h.definekey('x2','y2');
	h.definedata(all: 'yes');
	h.definedone();
    
	dcl hiter hi('h');
end;
*load the atm_data to find the nearest atm and calculate the distance;
set atm.atm_coords (where=(wsid ne '' and (x1 ne . or y1 ne .)) rename= (import_export_id = wsid)  );
n=_n_;


best = 999999; *initialize best distance to a ridiculous value;
best_id=''; *initialize if of best match;

rc=hi.first();

q = 1;
rc2=0;
do while (rc2=0);
	current = geodist(y1,x1,y2,x2);
	if current lt best and wsid ne wsid1 then do; *do not set best to be distance to self;
	    best = current; 
		best_id = wsid1;
	end;
	rc2=hi.next();
	q+1;
end;


keep x1 y1 best best_id wsid x2 y2 arrangement;
rename wsid=atm_id arrangement=group;
run;


*compare test1 to test2;

data test1a;
set test1;
where best eq current;
rename wsid=atm_id;
run;

proc sort data=test1a;
by n best;
run;


data test1a;
set  test1a;
by n;
if first.n then output;
run;

proc sort data=test1a;
by atm_id;
run;

proc sort data=test2;
by atm_id;
run;

data both;
merge test1a (keep=atm_id best_id best) test2(keep=atm_id best_id best rename=(best_id=best_id1 best=best1));
by atm_id;
run;

data both;
set both;
match = 0;
if best_id = best_id1 and best=best1 then match = 1;
diff = best1-best;
run;

proc freq data=both;
table match;
run;

proc sgplot data=both;
where match eq 0;
histogram diff;
run;

proc sgplot data=both;
vbox diff / group=match;
run;
