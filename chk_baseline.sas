
***************************************************************
* path is the path for the SDTM;
* out is the folder for the output; 
* sortvar is the domain/variables used to flag baseline; 
* A single record is flagged as baseline for the unique values 
* of USUBJID, xxTESTCD and sortvar; 
***************************************************************; 

%macro chk_baseline(path=, out=, sortvar=);
libname sdtm "&path";

filename out1 "&out/chk_baseline_flag.rtf";
%custom;
ods rtf file=out1 style=custom;

data banner; 
line= "No discrepancy found for Baseline Record Flag";
label line="Banner";
run;

%list_files(path=&path);

data f1; set f1;
name=scan(names,1, '.');
if upcase(substr(name,1,4))='SUPP' then delete;
run;

data _null_; 
set f1 end=eof;
i+1;
call symput(compress("dataset"||put(i,best.)), trim(left(name)));
if eof then call symput("tota", trim(left(put(_n_,best.))));
run;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine(keep=memname name); set %if &s=1 %then out1; %else combine out&s;; 
if length(name)>=4;
if substr(compress(reverse(name)),1,4)='LFLB';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine4(keep=memname name); set %if &s=1 %then out1; %else combine4 out&s;; 
if length(name)>=5;
if substr(compress(reverse(name)),1,5)='SERRO';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine5(keep=memname name); set %if &s=1 %then out1; %else combine5 out&s;; 
if length(name)>=6;
if substr(compress(reverse(name)),1,6)='DCTSET';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine2(keep=memname name); set %if &s=1 %then out1; %else combine2 out&s;; 
if substr(compress(reverse(name)),1,3)='CTD';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine6(keep=memname name); set %if &s=1 %then out1; %else combine6 out&s;; 
if substr(compress(reverse(name)),1,3)='TPT';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine7(keep=memname name); set %if &s=1 %then out1; %else combine7 out&s;; 
if substr(compress(reverse(name)),1,3)='QES';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine8(keep=memname name); set %if &s=1 %then out1; %else combine8 out&s;; 
if length(name)>=4;
if substr(compress(reverse(name)),1,4)='CEPS';
%end;

%do s=1 %to &tota;
proc contents data=sdtm.&&dataset&s noprint out=out&s;
data combine10(keep=memname name); set %if &s=1 %then out1; %else combine10 out&s;; 
if length(name)>=4;
if substr(compress(reverse(name)),1,4)='TATS';
%end;

** process the macro variable sortvar **;
data combine9(keep=memname varlist); 
length memname $10. varlist $200.; 
sortvar=upcase("&sortvar");
num=countw(sortvar,',');
if num=0 then do;
memname=' ';
varlist=' ';
output;
end;
else do k=1 to num;
list1=scan(sortvar,k,',');
memname=scan(list1,1,' ');
ind=index(list1, scan(list1,2,' '));
varlist=trim(left(substr(list1, ind )));
output;
end;
;

** put information together ** ;
proc sort data=combine; by memname name;
proc sort data=combine2; by memname;
proc sort data=combine4(rename=name=result); by memname;
proc sort data=combine5(rename=name=testcd); by memname;
proc sort data=combine6(rename=name=tpt); by memname;
proc sort data=combine7(rename=name=seq); by memname;
proc sort data=combine8(rename=name=spec); by memname;
proc sort data=combine9; by memname;
proc sort data=combine10(rename=name=stat); by memname;

proc transpose data=combine2 out=combine3(drop=_name_ _label_) prefix=date;
by memname; 
var name;
run; 

data combine;
merge combine(in=a) %do k=3 %to 10; combine&k %end;;
by memname;
if a;
len1=length(date1);
len2=length(date2);
if len1>=5;
if len1=5 then dtc=date1;
else if len2=5 then dtc=date2;
else if len1=7 and substr(reverse(compress(date1)),1,5)='CTDTS' then dtc=date1;
else if len2=7 and substr(reverse(compress(date2)),1,5)='CTDTS' then dtc=date2;
run;

title "Review of the variables used to derive xxBLFL";
footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";
footnote2 "Generated by chk_baseline.sas, &sysdate &systime SAS &sysver in &sysscpl";

%let column1=Dataset; 
%let column2=Basleine Flag Name; 
%let column3=Datetime of Assessment; 
%let column4=Result Variable; 
%let column5=Test Code; 
%let column6=Test Point; 
%let column7=Var to Derive xxBLFL; 
%let column8=Status; 
%report_rtf3(indata=combine, columns=%str(memname name dtc result testcd tpt varlist stat)); 
run;

data _null_; 
set combine end=eof;
i+1;
call symput(compress('dataset'||put(i,best.)), trim(left(memname)));
call symput(compress('variable'||put(i,best.)), trim(left(dtc)));
call symput(compress('blfl'||put(i,best.)), trim(left(name)));
call symput(compress('result'||put(i,best.)), trim(left(result)));
call symput(compress('testcd'||put(i,best.)), trim(left(testcd)));
call symput(compress('tpt'||put(i,best.)), trim(left(tpt)));
call symput(compress('seq'||put(i,best.)), trim(left(seq)));
call symput(compress('spec'||put(i,best.)), trim(left(spec)));
call symput(compress('varlist'||put(i,best.)), trim(left(varlist)));
call symput(compress('stat'||put(i,best.)), trim(left(stat)));

if eof then call symput('toti', trim(left(put(_n_,best.))));
run;


%do i=1 %to &toti;
proc sort data=sdtm.&&dataset&i out=&&dataset&i; by usubjid &&varlist&i &&testcd&i &&variable&i; 
proc sort data=sdtm.dm out=dm(keep=usubjid rfxstdtc); by usubjid;

data &&dataset&i; 
merge &&dataset&i(in=a) dm(in=b);
by usubjid;
if a;
date1=scan(&&variable&i,1,'T');
time1=scan(&&variable&i,2,'T');
date2=scan(rfxstdtc,1,'T');
time2=scan(rfxstdtc,2,'T');
len1=length(date1);
run;

** CREATE a flag bef_dose ** ; 
** bef_dose=0 is for after-dosing ** ; 

%if &&tpt&i ne %then %do;
data &&dataset&i; set &&dataset&i;
if index(upcase(&&tpt&i),'BEFORE') >0 or &&tpt&i=' ' or index(upcase(&&tpt&i), 'PRE-DOSE')>0 then bef_dose=1;
else bef_dose=0;
run;
%end;

%else %do; 
data &&dataset&i; set &&dataset&i;
bef_dose=1;
run;
%end;


%let tiaojian1=%str(((time1=' ' or time2=' ') and ' '<date1<substr(date2,1,len1))); *considered partial date; 
%let tiaojian2=%str(((time1=' ' or time2=' ') and len1=10 and (' '<date1=date2  and bef_dose=1) ));
%let tiaojian3=%str((time1>' ' and time2>' ' and  len1=10 and ' '<&&variable&i<=rfxstdtc));

proc sort data=&&dataset&i ;
by usubjid &&varlist&i &&testcd&i &&variable&i;

proc sort data=&&dataset&i out=base;
by usubjid  &&varlist&i &&testcd&i &&variable&i;
where &&result&i>' ' and (&&result&i notin ('N/A','NA')) and (&tiaojian1 or &tiaojian2 or &tiaojian3) %if &&stat&i ne %then %do; and index(&&stat&i,'NOT DONE')=0 %end;;
run;

** create the QC baseline record flag ** ;

proc sort data=base; by usubjid  &&varlist&i  &&testcd&i &&variable&i ;
proc sort data=&&dataset&i; by usubjid &&varlist&i  &&testcd&i &&variable&i ;

data base; set base;
by usubjid &&varlist&i &&testcd&i &&variable&i ;
if last.&&testcd&i;
run;

data &&dataset&i;
merge &&dataset&i(in=a) base(in=b keep=usubjid  &&testcd&i &&variable&i &&varlist&i);
by usubjid &&varlist&i &&testcd&i &&variable&i;
if b and bef_dose=1 then &&blfl&i.._qc='Y';
run;

** if more than one record are flagged a baseline, pick only one based on timepoint/sequence number **;

proc sort data=&&dataset&i out=temp nodupkey;
by usubjid &&varlist&i &&testcd&i &&tpt&i &&seq&i;
where &&blfl&i.._qc='Y' and &&result&i>' ';

proc sort data=temp; by usubjid  &&varlist&i &&testcd&i %if &&tpt&i ne %then %do; descending &&tpt&i %end; descending &&seq&i;
proc sort data=temp nodupkey; by usubjid  &&varlist&i &&testcd&i;
run;

proc sort data=&&dataset&i; by usubjid &&varlist&i &&testcd&i &&tpt&i &&seq&i;
data &&dataset&i;
merge &&dataset&i temp(in=b keep=usubjid &&varlist&i &&testcd&i &&tpt&i &&seq&i);
by usubjid  &&varlist&i &&testcd&i &&tpt&i &&seq&i;
if not b then &&blfl&i.._qc=' ';
run;

*** create the report *** ;

proc sql noprint;
select count(*) into :obs from &&dataset&i where &&blfl&i ne &&blfl&i.._qc;

%if &obs=0 %then %do;
title "QC of the &&blfl&i in &&dataset&i";
footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";
footnote2 "Generated by chk_baseline.sas, &sysdate &systime SAS &sysver in &sysscpl";

%let column1=; 
%report_rtf3(indata=banner, columns=%str(line)); 

run;
%end;

%else %do;

title "QC of the &&blfl&i in &&dataset&i";
footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";
footnote2 "Generated by chk_baseline.sas, &sysdate &systime SAS &sysver in &sysscpl";

%do k=1 %to 8;
%let column&k=; 
%end;
%report_rtf3(indata=&&dataset&i, where=%str(&&blfl&i ne &&blfl&i.._qc), columns=%str(usubjid  &&varlist&i &&tpt&i &&testcd&i &&variable&i rfxstdtc &&blfl&i &&blfl&i.._qc &&result&i)); 

run;
%end;
%end;


ods rtf close;
filename out1 clear;
proc datasets kill lib=work memtype=data nodetails nolist;
run;
%mend;




