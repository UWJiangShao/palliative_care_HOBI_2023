OPTIONS PS=MAX FORMCHAR="|----|+|---+=|-/\<>*" MPRINT;

** import SPSS data;

%let program = P01;
%let prog = SC;

libname temp "\\fed-ad.ufl.edu\T001\user\mydocs\jiang.shao\Desktop\SC";

proc import out=df_&prog._survey_BI
	datafile = "K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\Original (do not modify)\Final STARK23 data C7 rec.sav"
	dbms = SAV replace;
run;

proc import out=df_&prog._survey_ARC
	datafile = "K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\Original (do not modify)\ARCS23 all comps 09_21.sav"
	dbms = SAV replace;
run;

proc import out=df_&prog._sample
	datafile = "K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Sample\Orignal (do not modify)\STAR_Child_23_2303.xlsx"
	dbms = xlsx replace;
run;


proc contents data=df_&prog._survey_BI varnum out=contents_survey_BI(keep=name);
proc contents data=df_&prog._survey_ARC varnum out=contents_survey_ARC(keep=name);
proc contents data=df_&prog._sample varnum out=contents_sample(keep=name);
run;

proc sort data=contents_survey_BI;
	by name;
proc sort data=contents_survey_ARC;
	by name;
run;


data merge_contents;
	merge contents_survey_BI(in=a) contents_survey_ARC(in=b);
	by name;
	if a and b then source = '1.Common';
	else if a then source = '2.Biennial';
	else if a then source = '3.ARC';
run;

proc sort data=merge_contents;
	by source;
run;

proc print data=merge_contents;
run;


/** Check the survey data update survey_id:;*/
/*proc import out=df_&prog._survey_test*/
/*	datafile = "K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\Original (do not modify)\Final STARK23 data 0919.sav"*/
/*	dbms = SAV replace;*/
/*run;*/
/**/
/*proc sql;*/
/*create table comparison_survey as*/
/*select a.id as survey_id_1,*/
/*	   b.id as survey_id_2*/
/*	from df_&prog._survey as a*/
/*	full outer join*/
/*	df_&prog._survey_test as b*/
/*on */
/*	a.id = b.id*/
/*	where*/
/*	a.id is missing or b.id is missing;*/
/*quit;*/



*import dispositions;
proc import datafile="K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\ARCS23 Recs x Att.xlsx"
	dbms=xlsx replace out=disposition_ARC;
run;

proc import datafile="K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\STARK Recs x Att.xlsx"
	dbms=xlsx replace out=disposition_BI;
run;

data disposition;
	set disposition_ARC disposition_BI;
run;

data disposition;
	set disposition;
	survey_id=put(id, 15.);
run;

proc sort data=df_&prog._sample;
	by survey_id;
run;


** stack two survey data;
data df_&prog._survey;
	set df_&prog._survey_BI df_&prog._survey_ARC;
run;

proc sort data=df_&prog._survey;
	by id;
run;

proc sort data=disposition;
	by survey_id;
run;

data df_&prog._merge;
	merge 
		df_&prog._sample(keep=survey_id race age sex phi_plan_code AA_PCA) 
		df_&prog._survey(rename=(id=survey_id)) 
		disposition
		;
	by survey_id;
run;

data temp.&program._df_&prog._merge;
	set df_&prog._merge;
run;

* extract PCA members;
proc freq data=df_&prog._merge;
tables aa_pca;
run;

data df_&prog._pca;
	set df_&prog._merge;
	where aa_pca = 'PCA';
run;

* exclude pca from the merged dataset;
data df_&prog._merge;
	set df_&prog._merge;
	where aa_pca ne 'PCA';
run;


* extract AA memeber;
data df_&prog._AA;
	set df_&prog._merge;
	where aa_pca = 'AA';
run;

* attach the AA sample and pool member to the AA;
proc import datafile="K:\TX-EQRO\Research\Member_Surveys\CY2023\STAR Child ARC & Biennial\Data\ARCS23 Recs x Att.xlsx"
	dbms=xlsx replace out=disposition_ARC;
run;





