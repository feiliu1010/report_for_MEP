; This reads the individual file of OMI Near-Real-Time product and outputs 
; some important quantities. 
; Please do not distribute this code without Author's consent
; Lok Lamsal, 23 Sept 2010
; This code now reads nested-grid GEOS-Chem output for Asia
; Siwen Wang, 6 April 2011
; Fei Liu, 5 Aug 2013
PRO get_dpgc_data_NASA_flag2, fle_n, mtime, spx, sza, vzen, azi, vazi, $
                            latcorner, loncorner, g_lat, g_lon, $
                            ;slntcolno2, slntcolno2std, tm4slntcol, $
                            ;geoamf, amf, trpamf, 
			    ;no2cl, no2clstd, $
                            ;trp_flg, 
			    no2trp, no2trpstd,$
			    ;gvc, 
			    cfr, cldpre, $
                            ;spre,
			    sht, crd, salb, colerr,xtrack_flag 
fle=fle_n

data = H5_PARSE(fle, /READ_DATA)

;READ GEOLOCATION INFORMATION
g_lat  = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.latitude._data
g_lon  = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.longitude._data
latCorner = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.FoV75CornerLatitude._data
lonCorner = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.FoV75CornerLongitude._data
sza    = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.solarzenithangle._data
azi    = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.solarazimuthangle._data
vzen   = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.viewingzenithangle._data
vazi   = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.viewingazimuthangle._data
mtime  = data.hdfeos.swaths.ColumnAmountNO2.geolocation_fields.time._data
;DATA INFORMATION
;amf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactor._data
;geoamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactorgeometric._data
;trpamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactortropospheric._data
;ass_str_slntcolno2 = data.hdfeos.swaths.DOMINONO2.data_fields.$
;assimilatedstratosphericslantcolumn._data

cfr      = data.hdfeos.swaths.ColumnAmountNO2.data_fields.cloudfraction._data
cldpre   = data.hdfeos.swaths.ColumnAmountNO2.data_fields.cloudpressure._data
crd      = data.hdfeos.swaths.ColumnAmountNO2.data_fields.cloudradiancefraction._data
;gvc      = data.hdfeos.swaths.DOMINONO2.data_fields.ghostcolumn._data

;slntcolno2 = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2._data
;slntcolno2std = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2std._data

salb     = data.hdfeos.swaths.ColumnAmountNO2.data_fields.TerrainReflectivity._data
sht      = data.hdfeos.swaths.ColumnAmountNO2.data_fields.terrainheight._data
;spre     = data.hdfeos.swaths.DOMINONO2.data_fields.tm4surfacepressure._data

;no2cl    = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumn._data
;no2clstd = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumnerror._data
;trp_flg  = data.hdfeos.swaths.DOMINONO2.data_fields.troposphericcolumnflag._data
no2trp   = data.hdfeos.swaths.ColumnAmountNO2.data_fields.ColumnAmountNO2Trop._data
no2trpstd= data.hdfeos.swaths.ColumnAmountNO2.data_fields.ColumnAmountNO2TropStd._data

colerr = 100. * no2trpstd/no2trp

xtrack_flag =data.hdfeos.swaths.ColumnAmountNO2.data_fields.XTrackQualityFlags._data

dim = SIZE(g_lat)
ntrack = dim[1]
ntimes = dim[2]
ntr_vec = 1 + INDGEN(ntrack)
tgt_spix = ntr_vec
spx = ntr_vec # replicate(1, ntimes)


;;lat_sec = WHERE(g_lat LE 5. AND g_lat GE -30. AND $
;;                slntcolno2 GT 0. AND geoamf GT 0., n_lat_sec)

;sec_spix = spx[lat_sec]
;sec_orislnt = slntcolno2[lat_sec]
;;sec_amfs = geoamf[lat_sec]

;mn_spix  = LONARR(60)
;mn_slcol = FLTARR(60)
;;mn_amf   = FLTARR(60)

;FOR k = 0, 59 DO BEGIN
;    pck = WHERE (sec_spix EQ tgt_spix[k], npck)
;    if npck gt 0 then begin
;        mn_spix[k] = MEAN(sec_spix[pck])
    
;        s_sec_orislnt = sec_orislnt[pck]
                                ; calculate the mean of slant column
                                ; with data of 95% conf. for each subpixels
 ;       conf_min = percntle(s_sec_orislnt, 5)
 ;       conf_max = percntle(s_sec_orislnt, 95)
 ;       conf = WHERE(s_sec_orislnt GT conf_min and $
 ;                    s_sec_orislnt LT conf_max, ncnf)
 ;       mn_slcol[k] = MEAN(s_sec_orislnt[conf])            
                                ; calculate amf similar way
;;        s_sec_amfs    = sec_amfs[pck]
;;        conf_mina  = percntle(s_sec_amfs, 5)
;;        conf_maxa  = percntle(s_sec_amfs, 95)
;;        confa = WHERE(s_sec_amfs GT conf_mina and $
;;                      s_sec_amfs LT conf_maxa, ncnf)
;;        mn_amf[k] = MEAN(s_sec_amfs[confa])
;   endif
;NDFOR

;;delta_dal = mn_slcol - mn_amf * (mean(mn_slcol)/mean(mn_amf))
;;cor_slntcolno2 = slntcolno2  - delta_dal # replicate(1, ntimes)

; calculate tropospheric slant column
;tm4slntcol  = data.hdfeos.swaths.DOMINONO2.data_fields.ASSIMILATEDSTRATOSPHERICSLANTCOLUMN._data
;;tropslntcol = cor_slntcolno2 - tm4slntcol
;;tm4trppause = data.hdfeos.swaths.DOMINONO2.data_fields.TM4TROPOPAUSELEVEL._data
;;aks         = data.hdfeos.swaths.DOMINONO2.data_fields.AVERAGINGKERNEL._data * 0.001
;;pleva       = data.hdfeos.swaths.DOMINONO2.data_fields.TM4PRESSURELEVELA._data
;;plevb       = data.hdfeos.swaths.DOMINONO2.data_fields.TM4PRESSURELEVELB._data

;lev = (size(aks))[3]
;reslev = fltarr(ntrack, ntimes, nlev)
;catwts = fltarr(ntrack, ntimes, nlev)

;or y = 0, nlev - 1 do begin
    ;following documentation for temis product
;;    akstrop          = aks[*, *, y] * amf/trpamf
;;    scatwts[*, *, y] = akstrop * trpamf
;   preslev[*, *, y] =  pleva[y] * 0.01 + spre * plevb[y] 
;ndfor    

;find gc no2 profiles at the location of omi measurements
;flelen = strlen(fle_n)
;my_year  = strmid(fle_n, flelen-47, 4)
;my_month = strmid(fle_n, flelen-42, 2)
;my_day   = strmid(fle_n, flelen-40, 2)
;my_tt    = strmid(fle_n, flelen-37, 4)

;ymd = my_year + my_month + my_day 

;gc_fle = '/data1/lamsal/GEOS_Chem/For_A/sat_12_14.2006' + my_month + '.bpch'
;gc_file = '/z0/users/wangsiwen/GEOS_Chem/GC_201012/ts_2h_avg.'+ ymd +'.month.power.plant.bpch' 

;if (long(my_year) le 2007) then begin
;gc_file = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/GC_201012/ts_2h_avg.'+ ymd +'.month.power.plant.bpch'
;gc_file = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/GC_201012/ts_2h_avg.20050130.month.power.plant.bpch'
;endif else begin
;gc_file = '/z3/wangsiwen/GEOS_Chem/GEOS_05x0666/GC_201012/ts_2h_avg.2007'+my_month + my_day +'.month.power.plant.bpch'
;endelse

;print,gc_file

ctm_cleanup


END
