pro find_background_25
	nlon = 256
	nlat = 160
	;china density,limit=[15,72,55,136]
	no2 = fltarr(nlon,nlat)
	;emission from meic,limit=[15,70,60,140]
	nox = fltarr(nlon+24,nlat+20)
	nox_power= fltarr(nlon+24,nlat+20)
 	nox_other= fltarr(nlon+24,nlat+20)
	mask_nox = fltarr(nlon,nlat)

	year = 2010
	header = strarr(6,1)
	Yr4  = string(year,format='(i4.4)')
	filename = '/home/liufei/r5/report_for_MEP/Data/NO2/NASA_L2g/'+Yr4+'_Jan2Dec_Average_China_0.25X0.25.asc'
	openr,lun,filename,/get_lun
	readf,lun,header,no2
	
	print,'no2 eq -999',n_elements(where(no2 eq -999.0))
	no2[where(no2 ne -999.0)] = no2[where(no2 ne -999.0)]/(10.0^15)
	close,/all
	free_lun,lun
	

	filename_power = '/home/liufei/Data/Emission/MEIC/2010__power__NOx_25.asc'
	filename_other = '/home/liufei/Data/Emission/MEIC/2010__all__NOx_25.asc'
	
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
	mask_nox = nox[(72-70)/0.25:nlon+24-(140-136)/0.25-1,(60-55)/0.25:nlat+20-1]
	print,'size fo mask_nox',size(mask_nox)
	header_output = [['ncols 256'],['nrows 160'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.25'],['nodata_value -9999.0']]
	outfile = '/home/liufei/Data/Satellite/NO2/trend/mask_nox_0.25X0.25.asc'
	openw,lun,outfile,/get_lun
	printf,lun,header_output,mask_nox
	close,lun

	mask_no2 = no2
	mask_no2[where(mask_no2 le 1.0)]=-999.0
        header_output = [['ncols 256'],['nrows 160'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.25'],['nodata_value -999.0']]
        outfile = '/home/liufei/Data/Satellite/NO2/trend/mask_no2_le_1.0_0.25X0.25.asc'
        openw,lun,outfile,/get_lun
        printf,lun,header_output,mask_no2
        close,lun

	nox = mask_nox
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
	loc = where(no2 le 1.0)
	no2 =  no2[loc]
	nox = nox[loc]	
	plot,no2,nox,psym=2,$
		xrange = [min(no2),max(no2)],yrange=[min(nox),max(nox)],$
		title='nox/no2',xtitle='no2/(10^15molecules/cm^2)',ytitle='nox/t'
	print,'no2 le 1.0',n_elements(loc)
	print,'nox le 5.0 when no2 le 1.0',n_elements(where( nox le 5.0))
	
	image = tvrd(true =1)
	write_jpeg,'no2.jpg',image,true=1

	end	
