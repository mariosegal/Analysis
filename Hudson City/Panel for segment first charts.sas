%macro panel(x=,y=, fileout=,x_size=,y_size=);

goptions reset=all device=gif 
        gsfname=grafout gsfmode=replace 
       	xpixels=&x_size ypixels=&y_size cback=white;
		filename grafout "&fileout"; 
        %let xsize=%eval(100/&x);
		%let ysize=%eval(100/&y);

proc greplay igout=work.gseg tc=tempcat nofs;
  /* Define a custom template called NEWTEMP */
  tdef newtemp des="y=&y by x=&x panel template"

%do q = 1 %to &y;
  %do p = 1 %to &x; 
		%let panel = %eval(&p + (&q-1)*&x);
        %let s = %eval(&y+1-&q);
       &panel./llx=%eval((&p-1)*&xsize)   lly=%eval((&s-1)*&ysize)

	      lrx=%eval((&p)*&xsize)  lry=%eval((&s-1)*&ysize)

          ulx=%eval((&p-1)*&xsize)    uly=%eval((&s)*&ysize)

          urx=%eval((&p)*&xsize)  ury=%eval((&s)*&ysize)

          color=blue

	%end;
  %end;
  ;

	template newtemp;
    list template;

	treplay 1 : gchart
 			2 : gchart2
			3 : gchart4
			4 : gchart1
			5 : gchart3
			6 : gchart5
	;
run;
quit;

%mend panel;
