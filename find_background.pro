pro find_background
	nlon_g=2880
	nlat_g=1440
	;global density
	global = fltarr(nlon_g,nlat_g)

	nlon = 560
	nlat = 360
	;china density,limit=[15,70,60,140]
	no2 = fltarr(nlon,nlat)
	num = fltarr(nlon,nlat)
	no2_mon = fltarr(nlon,nlat,12)
	nox = fltarr(nlon,nlat)
	nox_power= fltarr(nlon,nlat)
 	nox_other= fltarr(nlon,nlat)
	;star point of grid for China in global map
	slon = (70+180)/0.125
	slat = (90-60)/0.125

	year = 2010
	header = strarr(7,1)
	;calculate yearly mean of NO2 density
	For month = 1,12 do begin
		Yr4  = string(year,format='(i4.4)')
		Mon2 = string(month,format='(i2.2)')
		filename = '/z6/satellite/OMI/no2/KNMI_L3/v2.0/no2_'+Yr4+Mon2+'.grd'
		;filename = '/z6/satellite/SCIAMACHY/no2/KNMI_v2.0/'+Yr4+'/no2_'+Yr4+Mon2+'.grd'
		openr,lun,filename,/get_lun
		readf,lun,header,global
		no2_mon[*,*,month-1] = global[slon:slon+nlon-1,slat:slat+nlat-1]/100	
		For J = 0, nlat-1 do begin
                	For I = 0, nlon -1 do begin
				if no2_mon[I,J,month -1] ge 0.0 then begin
					no2[I,J] += no2_mon[I,J,month -1]
					num[I,J] +=1
				endif 
			endfor
		endfor 				
	endfor
	close,/all
	free_lun,lun
	
	
	For J = 0, nlat-1 do begin
		For I = 0, nlon -1 do begin
			if num[I,J] gt 0L then begin
				no2[I,J] = no2[I,J]/num[I,J]
			endif else begin
				no2[I,J] = -999.0
			endelse

		endfor
	endfor

        header_output = [['ncols 560'],['nrows 360'],['xllcorner 70'],['yllcorner 15'],['cellsize 0.125'],['nodata_value -999.0'],['2010_KNMI_L3_yearly_mean le 1.0']]
        outfile = '/home/liufei/Data/Satellite/NO2/trend/mask_test.asc'
        openw,lun,outfile,/get_lun
        printf,lun,header_output,no2
        close,lun

	filename_power = '/home/liufei/Data/Emission/MEIC/2010__power__NOx_125.asc'
	filename_other = '/home/liufei/Data/Emission/MEIC/2010__all__NOx_125.asc'
	
	header2 = strarr(6,1)
	openr,lun,filename_power,/get_lun
        readf,lun,header2,nox_power

	openr,lun,filename_other,/get_lun
        readf,lun,header2,nox_other

	close,/all
	free_lun,lun
	
	
;	nox_power[where((nox_power  eq -9999.0) and (nox_other ne -9999.0))]=0.0
;	nox_other[where((nox_other eq -9999.0) and (nox_power ne -9999.0))] = 0.0
	nox = nox_power + nox_other
	nox[where( (nox_power eq -9999.0) and (nox_other eq -9999.0) )] = -9999.0
;	print,'sum of emissions',total(nox[where (nox ne -9999.0)])
	print,'no data in emission',n_elements( nox[where( (nox_power eq -9999.0) and (nox_other eq -9999.0) )])        
	print,'no data in satellite',n_elements(where(no2 eq -999.0))
;	save all source nox
	mask_nox = nox[(72-70)/0.125:nlon-(140-136)/0.125-1,(60-55)/0.125:nlat-1]
	header_output = [['ncols 512'],['nrows 320'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.125'],['nodata_value -9999.0'],['2010_MEIC_Total_emissions eq 0.0']]
	outfile = '/home/liufei/Data/Satellite/NO2/trend/mask_nox_eq_0.0_0.125X0.125.asc'
	openw,lun,outfile,/get_lun
	printf,lun,header_output,mask_nox
	close,lun

	mask_no2 = no2[(72-70)/0.125:nlon-(140-136)/0.125-1,(60-55)/0.125:nlat-1]
	mask_no2[where(mask_no2 le 1.0)]=-999.0
        header_output = [['ncols 512'],['nrows 320'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.125'],['nodata_value -999.0'],['2010_KNMI_L3_yearly_mean le 1.0']]
        outfile = '/home/liufei/Data/Satellite/NO2/trend/mask_no2_le_1.0_0.125X0.125.asc'
        openw,lun,outfile,/get_lun
        printf,lun,header_output,mask_no2
        close,lun


	loc = where((nox ne -9999.0) and (no2 ne -999.0))
	nox=nox[loc]
	no2=no2[loc]
	undefine,loc

	plot,nox,psym=2,$
        title='nox',ytitle='nox/t'
	image = tvrd(true =1)
        write_jpeg,'nox.jpg',image,true=1

	print,'mean of nox',mean(nox)

;	select background point: emissions=0.0 t	
;	loc = where(nox eq 0.0)
;	no2 = no2[loc]
;	nox = nox[loc]
;	select no2 le 1.0
	loc = where(no2 le 1.0)
	no2 =  no2[loc]
	nox = nox[loc]	
	plot,nox,no2,psym=2,$
		xrange = [min(nox),5.0],yrange=[min(no2),max(no2)],$
		title='no2/nox',xtitle='nox/t',ytitle='no2/10^15molecules/cm^2'
	print,'available sample number',n_elements(no2[where( nox le 5.0)])
	
	image = tvrd(true =1)
	write_jpeg,'no2.jpg',image,true=1

	end	
