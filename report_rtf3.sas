%macro report_rtf3(indata=, columns=, byval=, where=);

data col;
col="&columns";
numcol=countw(col);
do k=1 to numcol;
colname=scan(col,k);
output;
end;
run;

data _null_;
set col;
i+1;
call symput(compress('col'||put(i, best.)), trim(left(colname)));
call symput('numcol', trim(left(put(numcol,best.))));
run;

%if &byval ne %then %do;
proc sort data=&indata out=_&indata;
by &byval;
%end;

proc report data=&indata headline headskip 
                 missing split='^';

%if %length(&where)>0 %then %do;
where &where;
%end;

%if &byval ne %then %do;
by &byval;
%end;

columns %do k=1 %to &numcol; &&col&k %end;;

%do k=1 %to &numcol; 
define &&col&k/style(column)={just=left cellwidth=%sysevalf(8.8/&numcol) in} 
               style(header)={just=left cellwidth=%sysevalf(8.8/&numcol) in}  
               %if %length(&&column&k)>0 %then %do; "&&column&k" %end;
               flow;
%end;
run;

%mend;
