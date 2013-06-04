
*Append tags to demog data;

data tags;
set data.main_201206;
keep hhid tag_new;
run;



data data.demog_201206;
merge data.demog_201206 (in=a) tags (in=b);
by hhid;
run;

data data.demog_201206;
set data.demog_201206;
hh =1;
run;

*start analysis;

proc contents data=data.demog_201206 varnum short;
run;



proc tabulate data=data.demog_201206 missing out=demog_results order=data;
where tag_new ne '';
class year tag_new DEM_AGE CARD_IND DWELLING EDUCATION INCOME ETHNIC_CODE ETHNIC_ROLLUP HOME_EQUITY LTV HOME_OWNER 
    INCOME_ASSETS LANGUAG LENGTH_RESID MARITAL OCCUPATION POC_10 POC_11_15 POC_16_17 POC RELIGION VEHICLE 
    GENDER AGE_HOH /preloadfmt; 
var hh;
table hh*sum='HH Count'*f=comma12. ( DEM_AGE CARD_IND DWELLING EDUCATION INCOME  ETHNIC_ROLLUP  LTV HOME_OWNER 
    INCOME_ASSETS LANGUAG LENGTH_RESID MARITAL OCCUPATION POC_10 POC_11_15 POC_16_17 POC RELIGION VEHICLE 
    GENDER AGE_HOH)*(N*f=comma12. ), year*tag_new / nocellmerge;
table (DEM_AGE CARD_IND DWELLING EDUCATION INCOME  ETHNIC_ROLLUP  LTV HOME_OWNER 
    INCOME_ASSETS LANGUAG LENGTH_RESID MARITAL OCCUPATION POC_10 POC_11_15 POC_16_17 POC RELIGION VEHICLE 
    GENDER AGE_HOH)*(pctN<DEM_AGE CARD_IND DWELLING EDUCATION INCOME  ETHNIC_ROLLUP  LTV HOME_OWNER 
    INCOME_ASSETS LANGUAG LENGTH_RESID MARITAL OCCUPATION POC_10 POC_11_15 POC_16_17 POC RELIGION VEHICLE 
    GENDER AGE_HOH>*f=pctfmt.), year*tag_new / nocellmerge;
format income $incmfmt. marital $marital. home_owner $homeowner. occupation $ocupfmt. dem_age ageband. age_hoh ageband. education $educfmt. languag $language.
       ETHNIC_ROLLUP $demog_roll. LTV $ltv. income_assets $dem_assets. religion $religion. vehicle $vehicle. dwelling $dwelling. length_resid $residence. ;
run;

/*data demog_results_clean;*/
/*length field $ 30;*/
/*set demog_results;*/
/*where hh_sum eq .;*/
/*if dem_age ne . then field=put(dem_age, ageband.);*/
/*if CARD_IND ne '' then field=CARD_IND;*/
/*if DWELLING ne '' then field=DWELLING;*/
/*if EDUCATION ne '' then field=EDUCATION;*/
/*if INCOME ne '' then field=INCOME;*/
/*if ETHNIC_ROLLUP ne '' then field=ETHNIC_ROLLUP;*/
/*if LTV ne '' then field=LTV;*/
/*if HOME_OWNER ne '' then field=HOME_OWNER;*/
/*if INCOME_ASSETS ne '' then field=INCOME_ASSETS;*/
/*if LANGUAG ne '' then field=LANGUAG;*/
/*if LENGTH_RESID ne '' then field=LENGTH_RESID;*/
/*if MARITAL ne '' then field=MARITAL;*/
/*if OCCUPATION ne '' then field=OCCUPATION;*/
/*if POC_10 ne '' then field=POC_10;*/
/*if POC_11_15 ne '' then field=POC_11_15;*/
/*if POC_16_17 ne '' then field=POC_16_17;*/
/*if POC ne '' then field=POC;*/
/*if RELIGION ne '' then field=RELIGION;*/
/*if VEHICLE ne '' then field=VEHICLE;*/
/*if GENDER ne '' then field=GENDER;*/
/*if AGE_HOH ne '' then field=AGE_HOH;*/
/*run;*/

/*data demog_results_clean;*/
/*set demog_results;*/
/*where hh_sum eq .;*/
/*run;*/



proc format library=sas;
value $ residence (notsorted)	'00' = 'Up to 1 Yr'
                  	'01' = '1 Yr'
					'02' = '2 Yr'
					'03' = '3 Yr'
					'04' = '4 Yr'
					'05' = '5 Yr'
					'06' = '6 Yr'
					'07' = '7 Yr'
					'08' = '8 Yr'
					'09' = '9 Yr'
					'10' = '10 Yr'
					'11' = '11 Yr'
					'12' = '12 Yr'
					'13' = '13 Yr'
					'14' = '14 Yr'
					'15' = '15+ Yrs';
value $ dwelling 'S' = 'Single Fam'
                 'M' = 'Multiple Fam';
value $ vehicle    'A' = 'Luxury'
					'B' = 'Truck'
					'C' = 'SUV'
					'D' = 'Minivan'
					'E' = 'Regular'
					'F' = 'Upper'
					'G' = 'Basic Sporty';
value $ LTV (notsorted)		'K' = 'No Loans'
					'J' = 'Less than 50%'
					'I' = '50-59%'
					'H' = '60-69%'
					'G' = '70-74%'
					'F' = '75-79%'
					'E' = '80-84%'
					'D' = '85-89%'
					'C' = '90-94%'
					'B' = '95-99%'
					'A' = 'Over 100';
value $ demog_roll  'B' = 'ASIAN (NON-ORIENTAL)'
					'D' = 'SOUTHERN EUROPEAN'
					'F' = 'FRENCH'
					'G' = 'GERMAN'
					'H' = 'HISPANIC'
					'I' = 'ITALIAN'
					'J' = 'JEWISH'
					'M' = 'MISCELLANEOUS'
					'N' = 'NORTHERN EUROPEAN'
					'O' = 'ASIAN'
					'P' = 'POLYNESIAN'
					'R' = 'ARAB'
					'S' = 'SCOTTISH / IRISH'
					'Z' = 'AFRICAN AMERICAN'
					'U' = 'Default'
					'X' = 'NOT POSSIBLE TO CODE';
value $ religion  'B' = 'BUDDHIST'
				'C' = 'CATHOLIC'
				'G' = 'GREEK ORTHODOX'
				'H' = 'HINDU'
				'I' = 'ISLAMIC'
				'J' = 'JEWISH'
				'K' = 'SIKH'
				'O' = 'EASTERN ORTHODOX'
				'P' = 'PROTESTANT'
				'S' = 'SHINTO'
				'X' = 'Not Coded';
value $ language '01' = 'ENGLISH (DEFAULT)'
					'03' = 'DANISH'
					'04' = 'SWEDISH'
					'05' = 'NORWEGIAN'
					'06' = 'FINNISH'
					'07' = 'ICELANDIC'
					'08' = 'DUTCH'
					'10' = 'GERMAN'
					'12' = 'HUNGARIAN'
					'13' = 'CZECH'
					'14' = 'SLOVAKIAN'
					'17' = 'FRENCH'
					'19' = 'ITALIAN'
					'20' = 'SPANISH'
					'21' = 'PORTUGUESE'
					'22' = 'POLISH'
					'23' = 'ESTONIAN'
					'24' = 'LATVIAN'
					'25' = 'LITHUANIAN'
					'27' = 'GEORGIAN'
					'29' = 'ARMENIAN'
					'30' = 'RUSSIAN'
					'31' = 'TURKISH'
					'32' = 'GREEK'
					'34' = 'FARSI'
					'35' = 'MOLDAVIAN'
					'36' = 'BULGARIAN'
					'37' = 'ROMANIAN'
					'38' = 'ALBANIAN'
					'40' = 'SLOVENIAN'
					'41' = 'SERBO-CROATIAN'
					'44' = 'AZERI'
					'45' = 'KAZAKH'
					'46' = 'PASHTO'
					'47' = 'URDU'
					'48' = 'BENGALI'
					'49' = 'INDONESIAN'
					'51' = 'BURMESE'
					'52' = 'MONGOLIAN'
					'53' = 'CHINESE'
					'56' = 'KOREAN'
					'57' = 'JAPANESE'
					'58' = 'THAI'
					'59' = 'MALAY'
					'60' = 'LAOTIAN'
					'61' = 'KHMER'
					'62' = 'VIETNAMESE'
					'63' = 'SINHALESE'
					'64' = 'UZBEKI'
					'68' = 'HEBREW'
					'70' = 'ARABIC'
					'72' = 'TURKMENI'
					'73' = 'TAJIK'
					'74' = 'KIRGHIZ'
					'7A' = 'HINDI'
					'7E' = 'NEPALI'
					'7F' = 'SAMOAN'
					'80' = 'TONGAN'
					'86' = 'OROMO'
					'88' = 'GHA'
					'8G' = 'TIBETAN'
					'8I' = 'SWAZI'
					'8J' = 'ZULU'
					'8K' = 'XHOSA'
					'8M' = 'AFRIKAANS'
					'8O' = 'COMORIAN'
					'8S' = 'ASHANTI'
					'8T' = 'SWAHILI'
					'8X' = 'HAUSA'
					'92' = 'BANTU'
					'94' = 'DZONGHA'
					'95' = 'AMHARIC'
					'97' = 'TSWANA'
					'9E' = 'SOMALI'
					'9F' = 'MACEDONIAN'
					'9N' = 'TAGALOG'
					'9O' = 'SOTHO'
					'9R' = 'MALAGASY'
					'9S' = 'BASQUE'
                    other = 'Other/Missing';
value  $ dem_assets (notsorted) '0' = 'None'
								'A' = 'Less than $25M'
								'9' = '$25M - $50M'
								'8' = '$50M - $75M'
								'7' = '$75M - $100M'
								'6' = '$100M - $250M'
								'5' = '$250M - $500M'
								'4' = '$500M - $750M'
								'3' = '750M - $1,MM'
								'2' = '$1MM - $2MM'
								'1' = '$2MM+';
run;











