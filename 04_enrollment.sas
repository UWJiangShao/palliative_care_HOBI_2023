%include 'K:\TX-Data\Special_Projects\2023\Palliative Care\Program\jiang.shao\01_libname_setting.sas';



%macro enr(prg, prgL, yr);

/*This extra step becasue the current enrollment files in annual datasets have duplicates!*/
proc sort data= &prg..&prgL._enr_nodual_cy20&yr. nodupkey out=&prgL._enr_nodual_cy20&yr.;
by membno;
run;

data enr_&prg._&yr(keep=membno age bthdat age_GRP program months Year first_mon);
length Age_grp $15;
set &prgL._enr_nodual_cy20&yr.;
first_mon=find(flag, "1");
age=intck('year',bthdat,intnx('month', mdy(first_mon,15,20&yr.),0,'E'),'C');
if age>=0;
if age<21 then Age_GRP="0 to 20 yrs";
else if 64>=age>=21 then Age_GRP="21 to 64 yrs";
else Age_GRP="65+ yrs";
Year=20&yr.;
run;

%if &prg = SP %then %do;
data temp.enr_&prg._&yr;
merge enr_&prg._&yr(in=in1) Ed_exp_&prg._&yr.(in=in2) INP_exp_&prg._&yr.(in=in3) SNF_exp_&prg._&yr.(in=in4) 
		EDRX_exp_&prg._&yr. INPRX_exp_&prg._&yr.;
by membno;
if in1;
if in2 then ED=1;
if in3 then INP=1;
if in4 then SNF=1;
/*remove EDRX and INPrx expenditure from ED and INP total*/
if EDrx_exp<=0 then EDrx_exp=0;
if Ed_exp>0 then Ed_exp=Ed_exp-EDrx_exp;

if INPrx_exp<=0 then INPrx_exp=0;
if INP_exp>0 then INP_exp=INP_exp-INPrx_exp;

rx_exp=sum(EDrx_exp, INPrx_exp);
if rx_exp<=0 then RX_exp=0;
if ED_exp<=0 then ED_exp=0;
if INP_exp<=0 then INP_exp=0; 

if SNF_exp<=0 then SNF_exp=0;
run;

proc freq data=temp.enr_&prg._&yr;
tables age Age_GRP ED INP SNF/missing;
title"&PRG CY20&yr. enrollment";
run;
title;

title"&PRG CY20&yr. member expenditures";
proc means data=temp.enr_&prg._&yr. N Nmiss Mean sum Median Min max P10 P90;
var months RX_exp EDRX_exp INPRX_exp ED_exp INP_exp SNF_exp;

run;

title;

%end;

%else %do;
data temp.enr_&prg._&yr;
merge enr_&prg._&yr(in=in1) Ed_exp_&prg._&yr.(in=in2) INP_exp_&prg._&yr.(in=in3) 
		EDRX_exp_&prg._&yr. INPRX_exp_&prg._&yr.;
by membno;
if in1;
if in2 then ED=1;
if in3 then INP=1;

if EDrx_exp<=0 then EDrx_exp=0;
if Ed_exp>0 then Ed_exp=Ed_exp-EDrx_exp;

if INPrx_exp<=0 then INPrx_exp=0;
if INP_exp>0 then INP_exp=INP_exp-INPrx_exp;

rx_exp=sum(EDrx_exp, INPrx_exp);
if rx_exp<=0 then RX_exp=0;
if ED_exp<=0 then ED_exp=0;
if INP_exp<=0 then INP_exp=0;

run;


proc freq data=temp.enr_&prg._&yr;
tables age Age_GRP ED INP/missing;
title"&PRG CY20&yr. enrollment";
title; 
run;

title"&PRG CY20&yr. member expenditures";
proc means data=temp.enr_&prg._&yr N Nmiss Mean sum Median Min max P10 P90;
var months RX_exp EDrx_exp INPRX_exp ED_exp INP_exp;
run;

title;
%end;


%mend enr;

%enr(SK,STARKIDS,21);
%enr(SP,STARPLUS,21);
%enr(ST,STAR,21);

* %enr(SK,STARKIDS,22);
* %enr(SP,STARPLUS,22);
* %enr(ST,STAR,22);

* %macro together;
* %do yr= 21 %to 22;

* data All_enr_&yr.;
* set temp.enr_sk_&yr. temp.enr_sp_&yr. temp.enr_st_&yr. ;
* run;

* proc sort data=All_enr_&yr.;
* by membno first_mon;
* run;

* proc summary data=All_enr_&yr.;
* var months ED_exp INP_exp RX_exp SNF_exp ED INP SNF EDRX_exp INPRX_exp;
* by membno;
* output out=all_months_&yr. sum=;
* run;

* data unique_enr_&yr.;
* set All_enr_&yr.;
* by membno;
* if first.membno ;
* keep membno age bthdat age_GRP year first_mon program ;
* run;

* Data temp.enr_all_&yr.;
* merge unique_enr_&yr.(in=in1) all_months_&yr.;
* by membno;
* ED=(ED>=1);
* INP=(INP>=1);
* SNF=(SNF>=1);
* if program^="STAR+PLUS" then do;
* 	SNF=0;
* 	SNF_exp=0;
* end;

* if months>12 then months=12;
* drop _type_ _freq_;
* run;

* proc freq data=temp.enr_all_&yr.;
* tables program program*age_grp  program*ED program*INP program*SNF months/missing list;
* title"enrolled months CY20&yr.";
* run;
* title;

* %end;

* %mend together;

* %together


