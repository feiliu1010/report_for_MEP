pro no2_L2g_average
  ;scan file
  For year = 2010, 2012 do begin
    For month = 1,9 do begin
      For day = 1,31 do begin
        nymd = year*10000L+month*100L+day*1L
	Yr4 = string(year,format='(i4.4)')
        mon2 = string(month, format='(i2.2)')
        day2 = string(day, format='(i2.2)')

	 if total(nymd eq [20100229,20100230,20100231,20100431,20100631,20100931,20101131,$
                    20110229,20110230,20110231,20110431,20110631,20110931,20111131,$
                    20120230,20120231,20120431,20120631,20120931,20121131,$
		    20110420]) eq 1.0 then continue
	filename = file_search('/z6/satellite/OMI/no2/NASA_Grid/v_003/'+Yr4+'/OMI-Aura_L2G-OMNO2G_'+Yr4+'m'+Mon2+day2+'*.he5') 
      	if filename eq "" then begin
		print,nymd
	endif
	endfor
    endfor
  endfor
  print,'finish scan'


  For year = 2010, 2010 do begin
    ;yearly mean
    ;China: [72,15,136,55]
    nlon = 256
    nlat = 160
    no2 = fltarr(nlon,nlat)
    num = fltarr(nlon,nlat)
    For month = 1,9 do begin
      For day = 1,31 do begin
	nymd = year*10000L+month*100L+day*1L

	if total(nymd eq [20100229,20100230,20100231,20100431,20100631,20100931,20101131,$
		    20110229,20110230,20110231,20110431,20110631,20110931,20111131,$
		    20120230,20120231,20120431,20120631,20120931,20121131,$
		    20110420]) eq 1.0 then continue
	
	Yr4 = string(year,format='(i4.4)')
	mon2 = string(month, format='(i2.2)')
	day2 = string(day, format='(i2.2)')

	nlon_g = 1440
	nlat_g = 720
	no2_g = fltarr(nlon_g,nlat_g,15)
	no2_partial = fltarr(nlon,nlat,15)

	;no2_day for daily data
        no2_day = fltarr(nlon,nlat)

	filename = file_search('/z6/satellite/OMI/no2/NASA_Grid/v_003/'+Yr4+'/OMI-Aura_L2G-OMNO2G_'+Yr4+'m'+Mon2+day2+'*.he5')	
	file_id=H5F_OPEN(filename)
	dataset_id_CloudRadianceFraction=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/CloudRadianceFraction')
	CloudRadianceFraction=H5D_READ(dataset_id_CloudRadianceFraction)
	H5D_CLOSE,dataset_id_CloudRadianceFraction
	
	dataset_id_SolarZenithAngle=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/SolarZenithAngle')
	SolarZenithAngle=H5D_READ(dataset_id_SolarZenithAngle)
	H5D_CLOSE,dataset_id_SolarZenithAngle

        dataset_id_Latitude=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/Latitude')
        Latitude=H5D_READ(dataset_id_Latitude)
        H5D_CLOSE,dataset_id_Latitude
	
	dataset_id_Longitude=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/Longitude')
        Longitude=H5D_READ(dataset_id_Longitude)
        H5D_CLOSE,dataset_id_Longitude

	dataset_id_SceneNumber=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/SceneNumber')
        SceneNumber=H5D_READ(dataset_id_SceneNumber)
        H5D_CLOSE,dataset_id_SceneNumber
	
	dataset_id_ColumnAmountNO2Trop=H5D_OPEN(file_id,'/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/ColumnAmountNO2Trop')
	ColumnAmountNO2Trop=H5D_READ(dataset_id_ColumnAmountNO2Trop)
	H5D_CLOSE,dataset_id_ColumnAmountNO2Trop

	H5F_CLOSE,file_id

;	loc_lon_lat = where( (Longitude ge 72.0) and (Longitude le 136.0) and (Latitude ge 15) and (Latitude le 55) )
;	loc_cloud = where( CloudRadianceFraction lt 0.5)
;	loc_solar = where( SolarZenithAngle lt 70.0)
;	loc_scene = where( ((SceneNumber ge 5.0) and (SceneNumber lt 27.0)) or ((SceneNumber gt 45.0) and (SceneNumber lt 53.0)) ) 
	;setintersection
	 loc = where(  ( CloudRadianceFraction ge 500) or ( SolarZenithAngle ge 70.0) or ( (SceneNumber le 5) or  ((SceneNumber ge 28) and  (SceneNumber le 46)) or (SceneNumber ge 54 ) )   )	
;	print,'num of filter data',n_elements(loc)	
	no2_g = ColumnAmountNO2Trop
	no2_g[loc]=-999.0
	no2_partial= no2_g[(180+72)/0.25:(180+72)/0.25+nlon-1,(90+15)/0.25:(90+15)/0.25+nlat-1,*]
;	print,'size of ColumnAmountNO2Trop',size(ColumnAmountNO2Trop)
;	print,'size of no2_g',size(no2_g)
;	print,'size of no2_partial',size(no2_partial)
	For J = 0, nlat -1 do begin
		For I = 0,nlon-1 do begin
			temp = no2_partial[I,J,*]
			loc_t = where(temp ge 0.0)
			if array_equal(loc_t, [-1]) then begin
				no2_day[I,J] = -999.0
			endif else begin
				no2_day[I,J] = mean(temp[loc_t])
;				print,'temp[loc_t]',temp[loc_t],'mean temp[loc_t]',mean(temp[loc_t]),' no2_day[I,J]', no2_day[I,J]
				no2[I,J]+= no2_day[I,J]
                       		num[I,J]+= 1
			endelse
			undefine,temp
			undefine,loc_t
                endfor
        endfor
     print,nymd 
     endfor
    endfor

    For J = 0, nlat -1 do begin
	For I = 0,nlon-1 do begin
		if num[I,J] le 0L then begin
			 no2[I,J]=-999.0
		endif else begin
			 no2[I,J]= no2[I,J]/num[I,J]
		endelse
	endfor
    endfor
    

  ; reverse 
  for j=1, nlat/2 do begin
	tmp = no2[*,j-1]
	no2[*,j-1] = no2[*,nlat-j]
	no2[*,nlat-j] = tmp
  endfor
  undefine, tmp

  header_output = [['ncols 256'],['nrows 160'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.25'],['nodata_value -999.0']]
  outfile ='/home/liufei/r5/report_for_MEP/Data/NO2/NASA_L2g/'+Yr4+'_Jan2Sep_Average_China_0.25X0.25.asc'
  openw,lun,outfile,/get_lun
  printf,lun,header_output,no2
  close,lun

  endfor


end
