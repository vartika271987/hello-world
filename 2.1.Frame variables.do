*Testing here
*Paths
******Generating frames for CACP data
******Created by: Shweta Gupta
******Date of creation: 15-01-2020
******Last modified: 1st Feb, 2021

{	
clear all
	set more off, permanently
	version 16
	global avinash 0
	global shweta 1
	global vartika 0

	if $shweta { 
		global source "C:\Users\shwetagupta\Dropbox (IFPRI)\CACP DATA_Shweta"
	}
	
	if $vartika { 
		global source "C:\Users\vartikasingh\Dropbox (IFPRI)\CACP DATA (1)"
	}
	cd "$source"
	graph set window fontface "Bell MT"

	//use "$source\Data\Cleaned_data.dta", clear
	use "$source\Data\Cleaned_data_allcrops.dta", clear
	
}		

****************************************************************
*DOING THE FOLLOWING FOR ALL CROPS IN THEIR RESPECTIVE FRAMES
****************************************************************

*generating frames
*****************************
{
	frames copy default paddy_fullyear
	frame paddy_fullyear {
	keep if crop=="Paddy"
	global crop pad
	}
	frames copy default wheat_fullyear
	frame wheat_fullyear {
	keep if crop=="Wheat"
	global crop wht
	}
	frames copy default paddy_wheat
	frame paddy_wheat {
	keep if crop=="Paddy"| crop=="Wheat"
	keep if state=="Bihar"|state=="Haryana"|state=="Punjab"|state=="Uttar Pradesh"
	gen crop_original=crop
	replace crop="paddy_wheat" if crop=="Paddy"|crop=="Wheat"
	}
	frames copy default paddy_kharif
	frame paddy_kharif {
	keep if crop=="Paddy"
	keep if season==1
	}
}


replace crop="Cassava" if strpos(crop,"Cassava")
levelsof crop, clean
return list
global cropnames `r(levels)'
foreach x in $cropnames {
	frames copy default `x'_fullyear
	frame `x'_fullyear {
	keep if crop=="`x'"
	}
}

frames dir
return list
global framename `r(frames)'
foreach x in Arhar_fullyear Bajra_fullyear Barley_fullyear Cassava_fullyear Coconut_fullyear Cotton_fullyear Gram_fullyear Groundnut_fullyear Jowar_fullyear Jute_fullyear Maize_fullyear Masoor_fullyear Moong_fullyear Mustard_fullyear Nigerseed_fullyear Onion_fullyear Paddy_fullyear paddy_wheat Pea_fullyear Potato_fullyear Ragi_fullyear Safflower_fullyear Sesamum_fullyear Soyabean_fullyear Sugarcane_fullyear Sunflower_fullyear Urad_fullyear Wheat_fullyear  {
*foreach x in  Paddy_fullyear Wheat_fullyear paddy_wheat {
frame change `x'

*_______________________________________________________________________________
*VARIABLES CREATION 
*(MUST RUN)

*Area under the crop variable for state and india level 
*****************************
order id id_2 year state2 zonecode tehsilcode sizegroup cultivatorno parcel plot season crop2 cropareaha
sort id year id_2 parcel plot season state2 zonecode tehsilcode sizegroup 
br id year id_2 parcel plot season state2 zonecode tehsilcode sizegroup clusterfactor cropareaha
{	
*tehsil or village level
	bysort year state crop zonecode tehsilcode sizegroup: egen Areazim= total(cropareaha)
	gen Areazim_factor= Areazim*cluster
	bysort year state crop zonecode tehsilcode sizegroup: gen id1=_n //identifier for each plot within a size group
	replace Areazim_factor= . if id1!=1
	bysort year state crop zonecode tehsilcode : egen Areazi= total(Areazim_factor)

	*zone level
	gen Areazi_hat= Areazi/(noofvillagesintehsil*areaofselectedcropsinvillag)
	replace Areazi_hat= Areazi_hat*areaofselectedcropinzoneh/(nooftehsilsinzone*sampletehsilsinzone)
	bysort year state crop zonecode tehsilcode : gen id2=_n //identifier for each plot within a tehsil
	replace Areazi_hat= . if id2!=1
	bysort year state crop zonecode : egen Areaz_bar= total(Areazi_hat)

	*state level
	bysort year state crop zonecode: gen id3=_n //identifier for each plot within a zone
	gen Acz= areaofcropinzoneha
	replace Acz=. if id3!=1
	bysort year state crop: egen Acs= total(Acz)

	*india level
	bysort year state crop : gen id4=_n
	gen area_state=Acs
	replace area_state= . if id4!=1
	bysort year crop: egen area_india= sum(area_state)
	
	*drop Areazim Areazim_factor Areazi Areazi_hat
}

*Doing the same as above, but for each land class now
*****************************
{	
/*    
sort id year id_2 parcel plot season state2 zonecode tehsilcode sizegroup 
br id year id_2 parcel plot season state2 zonecode tehsilcode sizegroup clusterfactor cropareaha

	keep if sizegroup==1 
	*tehsil or village level
	bysort id_year crop: egen Areazim_1= total(cropareaha) 
	gen Areazim_factor_1= Areazim_1*cluster 
	bysort id_year: gen id1_1=_n 
	replace Areazim_factor_1= . if id1_1!=1 
	bysort year state crop zonecode tehsilcode : egen Areazi_1= total(Areazim_factor_1) 

	*zone level
	gen Areazi_hat_1= Areazi_1/(noofvillagesintehsil*areaofselectedcropsinvillag) 
	replace Areazi_hat_1= Areazi_hat_1*areaofselectedcropinzoneh/(nooftehsilsinzone*sampletehsilsinzone)
	bysort year state crop zonecode tehsilcode : gen id2_1=_n 
	replace Areazi_hat_1= . if id2_1!=1 
	bysort year state crop zonecode : egen Areaz_bar_1= total(Areazi_hat_1) 

	*state level
	bysort year state crop zonecode: gen id3_1=_n 
	gen Acz_1= areaofcropinzoneha   
	replace Acz_1=. if id3_1!=1 & sizegroup==1
	bysort year state crop: egen Acs_1= total(Acz_1) //this is still area unde rthe crop foir the entuire state (not just for the particular size group)

	*india level
	bysort year state crop : gen id4_1=_n 
	gen area_state_1=Acs_1 
	replace area_state_1= . if id4_1!=1 & sizegroup==1
	bysort year crop: egen area_india_1= sum(area_state_1)  //entire india area
	drop Areazim_1 Areazim_factor_1 Areazi_1 Areazi_hat_1
}
*/
}

*Inputs per hectare
*VARIABLES TO BE GRAPHED
*****************************
{	
	gen totallabourhrs= casuallabourhrs + familylabourhrs + attachedlabourhrs
	gen totallabourhrs_new= casuallabourhrs + familylabourhrs 
		
	gen totalmachinehrs= ownmachinehrs + hiredmachinehrs 
	gen totalmachiners_new= ownmachiners + hiredmachiners
	gen irrigationhrs= ownirrigationmachinehrs + hiredirrigationmachinehrs 
	gen allmachinehrs= totalmachinehrs+irrigationhrs

	gen totalanimalhrs= hiredanimallabourhrs + ownedanimallabourhrs

	gen totallabourrs= casuallabourrs + familylabourrs + attachedlabourrs
	gen totalmachiners= ownmachiners + hiredmachiners
	gen totalanimalrs= hiredanimallabourrs + ownedanimallabourrs
	gen irrigationrs= ownirrigationmachiners + hiredirrigationmachiners + canalandotherirrigationcharg
	gen fixed_cost= landrevenuers +rentpaidforleasedinlandrs +imputedrentrs +totaldepreciationrs 
	gen allmachiners= totalmachiners+irrigationrs
	
	gen cost_cultivation= totallabourrs+  totalmachiners+  totalanimalrs +irrigationrs+ seedvaluers+ totalfertiliserrs +manurers +insecticidesrs +miscelaneouscostrs+fixed_cost
	gen cost_cultivation_irri = totallabourrs+  totalmachiners+  totalanimalrs +irrigationrs+ seedvaluers+ totalfertiliserrs +manurers +insecticidesrs +miscelaneouscostrs+fixed_cost if irrigationrs != 0
	gen cost_cultivation_rain = totallabourrs+  totalmachiners+  totalanimalrs +irrigationrs+ seedvaluers+ totalfertiliserrs +manurers +insecticidesrs +miscelaneouscostrs+fixed_cost if (irrigationrs == 0 | irrigationrs == .)

	*gen net_return= vop_mainproduct-cost_cultivation
}

*GENERATING PER HECTARE VARIABLES	
*simple non-monetary per hectare vars
*****************************
{

global varlist fertilisernkg fertiliserpkg fertiliserkkg otherfertiliserkg totalfertiliserkg ///
               manureqtl ///
			   mainproductqtls ///
			   totallabourhrs_new totallabourhrs familylabourhrs casuallabourhrs attachedlabourhrs ///
			   totalanimalhrs ///
			   seedqtykg ///
			   totalmachinehrs ownmachinehrs hiredmachinehrs allmachinehrs ///
			   ownedanimallabourhrs hiredanimallabourhrs ///
			   irrigationhrs 

foreach x in $varlist  {
	*tehsil `i' or village level
	bysort year state crop zonecode tehsilcode sizegroup: egen `x'zim= total(`x')
	gen `x'zim_factor= `x'zim*clusterfactor
	replace `x'zim_factor= . if id1!=1
	bysort year state crop zonecode tehsilcode : egen `x'zi= total(`x'zim_factor)

	*zone `z' level
	gen `x'zi_hat= `x'zi/(noofvillagesintehsil*areaofselectedcropsinvillag)
	replace `x'zi_hat= `x'zi_hat*areaofselectedcropinzoneh/(nooftehsilsinzone*sampletehsilsinzone)
	replace `x'zi_hat= . if id2!=1
	bysort year state crop zonecode : egen `x'z_bar= total(`x'zi_hat)
	gen `x'_hec_zone= `x'z_bar/Areaz_bar

	*state level
	replace `x'_hec_zone=. if id3!=1
	bysort year state crop: gen x1= `x'_hec_zone*Acz
	replace x1= x1/Acs
	bysort year state crop:egen `x'cs= total(x1)
	*br state crop year `x'cs  if crop=="Paddy" & year>2003
	drop x1

	*national level
	bysort year crop: gen `x'_india2= `x'cs*area_state/area_india
	bysort year crop: egen `x'_india= total(`x'_india2)
	drop `x'_india2 `x'zim `x'zim_factor `x'zi_hat `x'z_bar
	}
}	

*monetary per hectare vars
*****************************
{
	
*this is a separate code just for the nominal variables that need to be deflated.
*we use state cpi to deflate state values per hectare. these state deflated values are then used to generate national values
*if national cpi are used then deflator gets cancelled from numerator and denominator	
rename ownirrigationmachiners ownirrimachrs
rename hiredirrigationmachiners hiredirrimachrs
rename canalandotherirrigationcharg canalirrirs
global varlist2 fertilisernrs fertiliserprs fertiliserkrs otherfertiliserrs totalfertiliserrs manurers insecticidesrs ///
                mainproductrs ///
				casuallabourrs attachedlabourrs familylabourrs totallabourrs ///
				totalmachiners_new   totalmachiners hiredmachiners ownmachiners  ///
				totalanimalrs  hiredanimallabourrs ownedanimallabourrs ///
				irrigationrs ownirrimachrs hiredirrimachrs canalirrirs allmachiners seedvaluers  ///
				misc ///
				fixed_cost ///
				cost_cultivation cost_cultivation_irri cost_cultivation_rain

foreach x in $varlist2  {
	*tehsil or village level
	bysort year state crop zonecode tehsilcode sizegroup: egen `x'zim= total(`x')
	gen `x'zim_factor= `x'zim*clusterfactor
	replace `x'zim_factor= . if id1!=1
	bysort year state crop zonecode tehsilcode : egen `x'zi= total(`x'zim_factor)

	*zone level
	gen `x'zi_hat= `x'zi/(noofvillagesintehsil*areaofselectedcropsinvillag)
	replace `x'zi_hat= `x'zi_hat*areaofselectedcropinzoneh/(nooftehsilsinzone*sampletehsilsinzone)
	replace `x'zi_hat= . if id2!=1
	bysort year state crop zonecode : egen `x'z_bar= total(`x'zi_hat)
	gen `x'_hec_zone= `x'z_bar/Areaz_bar
	
// 	*generating total monetary value 
// 	gen `x'_zone_total= `x'_hec_zone*areaofcropinzoneha //zone level
// 	replace `x'_zone_total=. if id3!=1
// 	bysort year state crop: egen `x'_state_total= total(`x'_zone_total) //state level
// 	replace `x'_state_total=. if id4!=1
// 	bysort year crop: egen `x'_india_total=total(`x'_state_total)
	
	*state level
	replace `x'_hec_zone=. if id3!=1
	bysort year state crop: gen x1= `x'_hec_zone*Acz
	replace x1= x1/Acs
	bysort year state crop:egen `x'cs= total(x1)
	*br state crop year `x'cs  if crop=="Paddy" & year>2003
	drop x1
	generate `x'cs_def= `x'cs*100/cpistate_2017 //state nominal value deflated by state cpi (2017=100)

	*national level
	bysort year crop: gen `x'_india2= `x'cs_def*area_state/area_india
	bysort year crop: egen `x'_india= total(`x'_india2) //deflated
	drop `x'_india2 `x'zim `x'zim_factor `x'zi_hat `x'z_bar
	
	bysort year crop: gen `x'_india2_nom= `x'cs*area_state/area_india
	bysort year crop: egen `x'_india_nom= total(`x'_india2_nom) //undeflated
	drop `x'_india2_nom
	}
	
}

*creating national per hectare vars using state based dataset (state level excel files downloaded from DES)
*****************************
{
	/*
	ds animal_labor_price_st coc_*_st cop_*_st depreciation_st fertilizer_price_st fixed_cost_st  human_labor_price_st  implicit_rate_perqtl_st interest_fc_st interest_wc_st land_revenue_st  manure_price_st rent_leasedland_st rent_ownland_st seed_price_st  total_cost_st vop_byproduct_st vop_mainproduct_st  
 	global statevars `r(varlist)'
	foreach x in $statevars {
	bysort year crop: gen `x'_india2= (`x'*100*area_state)/(area_india*cpistate_2017)
	bysort year crop: egen `x'_india= total(`x'_india2)
	}
	
	ds animal_labor_paid_hrs_st attached_labor_hr_st casual_labor_hr_st derived_yield_st family_labor_hr_st fertilizer_kg_st  human_labor_hrs_st  manure_qtl_st number_holdings_st number_tehsil_st seed_kg_st total_labor_hr_st
	global statevars2 `r(varlist)'
	foreach x in $statevars2 {
	bysort year crop: gen `x'_india2= `x'*area_state/area_india
	bysort year crop: egen `x'_india= total(`x'_india2)
	*/


// 	ds 
// 	ds *_india
// 	global set2 `r(varlist)'
// 	ds *cs
// 	global set3 `r(varlist)'
// 	ds *cs_def
// 	global set4 `r(varlist)'
// 	global set5 $set1 $set2 $set3 $set4 $state_data
}

*variables for 5 land classes
*****************************
{
/*
	*set trace on
    global varlist totalmachinehrs hiredmachinehrs ownmachinehrs

foreach x in $varlist  {
	keep if sizegroup==1
	*tehsil `i' or village level
	bysort id_year crop: egen `x'zim_1= total(cropareaha) 
	gen `x'zim_factor_1= `x'zim_1*cluster 
	replace `x'zim_factor_1= . if id1!=1 
	bysort id_year crop : egen `x'zi_1= total(`x'zim_factor_1) 

	*zone `z' level
	gen `x'zi_hat_1= `x'zi_1/(noofvillagesintehsil*areaofselectedcropsinvillag) 
	replace `x'zi_hat_1= `x'zi_hat_1*areaofselectedcropinzoneh/(nooftehsilsinzone*sampletehsilsinzone) 
	replace `x'zi_hat_1= . if id2_1!=1 
	bysort year state crop zonecode : egen `x'z_bar_1= total(`x'zi_hat_1)  
	gen `x'_hec_zone_1= `x'z_bar_1/Areaz_bar_1 
	*state level
	replace `x'_hec_zone_1=. if id3_1!=1 & sizegroup==1
	bysort year state crop: gen x1_1= `x'_hec_zone_1*Acz_1 
	replace x1_1= x1_1/Acs_1  
	bysort year state crop:egen `x'cs_1= total(x1_1)  
	drop x1_1

	*national level
	bysort year crop: gen `x'_india2_1= `x'cs_1*area_state_1/area_india_1  
	bysort year crop: egen `x'_india_1= total(`x'_india2_1)  
	drop `x'_india2_1 `x'zim_1 `x'zim_factor_1 `x'zi_hat_1 
	}
}	
*/
}

*saving the respective frames with the data created above
{
	frame
	global graph "C:\Users\shwetagupta\Dropbox (IFPRI)\CACP DATA_Shweta\Graphs\plotwise data based\using weights\\`r(currentframe)'"
	di `"$graph"'
	
	levelsof crop , clean
	gen price_`r(levels)'_state= mainproductrscs/mainproductqtlscs
	gen price_`r(levels)'_india= mainproductrs_india/mainproductqtls_india
	order price*, a(crop2)

	frame
	save "$source\Data\State and national avg `r(currentframe)'", replace
	
}
}

exit

/*
frame change wheat_fullyear
gen wheat_price=       mainproductrs_india/mainproductqtls_india
preserve
collapse (mean) paddy_price, by(year2 crop)
twoway line paddy_price year2, xlabel(1(2)15, val angle(0) labsize(medium))  ytitle(Price of paddy (Rs/quintal)) graphregion(color(white)) xsize(7) xtitle("")
restore
*/

cd "$source\Data"
use "State and national avg paddy_kharif.dta"
