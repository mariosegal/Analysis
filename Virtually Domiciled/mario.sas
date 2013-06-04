ods escapechar "^";
options orientation=landscape;

proc report data=wip.matrix_results_summary nowd split='\' ps=50 out=x; 
column Segment segment_new,(flag_2009_sum  flag_2012_sum contrib_mean contrib_12_mean svcs_mean svcs_12_mean age_mean age_12_mean block);
define segment / group order=data ; 
define segment_new / across order=data ; 
define flag_2009_sum / analysis noprint ; 
define flag_2012_sum / analysis noprint; 
define contrib_mean / analysis noprint; 
define contrib_12_mean / analysis noprint; 
define  svcs_mean / analysis noprint;
define  svcs_12_mean / analysis noprint;
define  age_mean / analysis noprint;
define  age_12_mean / analysis noprint;
define block / computed width=25 ''; 
compute block / char length=250;
   array cols{96}   _c2_ _c3_ _c4_ _c5_ _c6_ _c7_ _c8_ _c9_
     _c11_ _c12_ _c13_ _c14_ _c15_ _c16_ _c17_   _C18_
     _c20_ _c21_ _c22_ _c23_ _c24_ _c25_ _c26_   _C27_
     _c29_ _c30_ _c31_ _c32_ _c33_ _c34_ _c35_   _C36_
     _c38_ _c39_ _c40_ _c41_ _c42_ _c43_ _c44_   _C45_
     _c47_ _c48_ _c49_ _c50_ _c51_ _c52_ _c53_   _C54_
     _c56_ _c57_ _c58_ _c59_ _c60_ _c61_ _c62_   _C63_
	 _c65_ _c66_ _c67_ _c68_ _c69_ _c70_ _c71_ _c72_
     _c74_ _c75_ _c76_ _c77_ _c78_ _c79_ _c80_   _C81_
     _c83_ _c84_ _c85_ _c86_ _c87_ _c88_ _c89_   _C90_
     _c92_ _c93_ _c94_ _c95_ _c96_ _c97_ _c98_   _C99_
     _c101_ _c102_ _c103_ _c104_ _c105_ _c106_ _c107_  _c108_; 
   array blocks(12)     _c10_  _c19_  _c28_  _c37_  _c46_  _c55_  _c64_  _c73_  _c82_  _c91_  _c100_  _c109_;
   do i = 1 to 12;
     aux=8*(i-1);
          blocks{i} = 'N= ' || put(max(cols{(aux+1)} , cols{(aux+2)}),comma12.0) 
          || '^nContrib (2009) = ' || put( cols{(aux+3)}, dollar12.2)
          || '^nContrib (2012) = ' || put(cols{(aux+4)}, dollar12.2)
          || '^nSvcs (2009) = ' || put( cols{(aux+5)}, comma12.1) 
          || '^nSvcs (2012) = ' || put( cols{(aux+6)}, comma12.1)
          || '^nAvg. Age = ' || put( max(cols{(aux+7)},cols{(aux+8)}), comma12.1);
 end;
    

endcomp;
run;
