%include 'K:\TX-Data\Special_Projects\2023\Palliative Care\Program\jiang.shao\01_libname_setting.sas';

%macro condi(prg,prgL,yr);
Data temp.DME_&prg._&yr.;
set &prg..&prgl._enc_cy20&yr.(keep=membno dfrdos clmno plancod svccod clmstat d_clmstat);
where svccod in (&A_DME.) and membno not in ('' '000000000');
DME=1;
run;




proc sort data=&prg..&prgl._enc_cy20&yr.(keep=membno dfrdos clmno plancod clmstat diagn1-diagn25 ) nodupkey 
	out=&prg._diag_20&yr.;
by membno clmno plancod;
run;


Data temp.&prg._diag_20&yr.;
length diag_cd $10;
set &prg._diag_20&yr.;
array D(*) diagn1-diagn25;
do i=1 to dim(D) while ( D(i)^='');
	if d(i) in: (&A_Cancer) or d(i) in:(&A_heart) or d(i) in:(&A_renal) or d(i) in:(&A_stroke)
	or d(i) in:(&A_alzheimer) or d(i) in:(&A_cirrhosis) or d(i) in:(&A_frailty)
	or d(i) in:(&A_lung_failure) or d(i) in:(&A_neurodegenerative) or d(i)in (&A_hiv_aids)
	then do;
		adult_con=1;
		diag_CD=d(i);
		output;
	end;

	if d(i) in:(&A_diabetes_w_complications) then do;
		diabete=1;
		diag_CD=d(i);
		output;
	end;

	if d(i) in:(&A_diabetes_severe_complications) then do;
		comorbid=1;
		diag_CD=d(i);
		output;
	end;

	/*pediatric */
	if d(i) in: (&P_neuro) or d(i) in:(&P_cardio) or d(i) in:(&P_resp) 
	or d(i) in: (&P_renal) or d(i) in:(&P_gastro) or d(i) in:(&P_hemo)
	or d(i) in: (&P_metab) or d(i) in:(&P_congen) or d(i) in:(&P_maligcy)
	or d(i) in: (&P_premature) or  d(i) in:(&P_misc) 
	then do;
		ped_con=1;
		diag_CD=d(i);
		output;
	end;

end;

run;



%mend condi;

%condi(SP, STARPLUS, 21)
%condi(ST, STAR, 21)
%condi(SK, STARkids, 21)
%condi(p200, PRG200, 21)

/* %condi(SP, STARPLUS, 22)
%condi(ST, STAR, 22)
%condi(SK, STARkids, 22)
%condi(p200, PRG200, 22) */
