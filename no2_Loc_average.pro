pro no2_Loc_average
  ;scan file
  For year = 2005, 2010 do begin
    For month = 1,12 do begin
      For day = 1,31 do begin
        nymd = year*10000L+month*100L+day*1L
        Yr4 = string(year,format='(i4.4)')
        mon2 = string(month, format='(i2.2)')
        day2 = string(day, format='(i2.2)')

         if total(nymd eq [20040229,20040230,20040231,20040431,20040631,20040931,20041131,$
                        20050229,20050230,20050231,20050431,20050631,20050931,20051131,$
                        20060229,20060230,20060231,20060431,20060631,20060931,20061131,$
                        20070229,20070230,20070231,20070431,20070631,20070931,20071131,$
                        20080229,20080230,20080231,20080431,20080631,20080931,20081131,$
                        20090229,20090230,20090231,20090431,20090631,20090931,20091131,$
                        20100229,20100230,20100231,20100431,20100631,20100931,20101131,$
                        20110229,20110230,20110231,20110431,20110631,20110931,20111131,$
                        20120230,20120231,20120431,20120631,20120931,20121131,$
			20060228,20060301,20060302,20080928,20080929 ])$
                        eq 1.0 then continue
        filename = file_search('/z6/satellite/OMI/no2/OMI_Lok/'+Yr4+'/'+Yr4+'_'+Mon2+'_'+Day2+'_NO2TropCS30.hdf5')
        if filename[0] eq "" then begin
                print,nymd
        endif
        endfor
    endfor
  endfor
  print,'finish scan'

  For year = 2009, 2009 do begin
    nlon_g = 3600
    nlat_g = 1800
    no2 = fltarr(nlon_g,nlat_g)
    number = fltarr(nlon_g,nlat_g)

    For month = 1,12 do begin
      For day = 1,31 do begin
        nymd = year*10000L+month*100L+day*1L
        Yr4 = string(year,format='(i4.4)')
        mon2 = string(month, format='(i2.2)')
        day2 = string(day, format='(i2.2)')

         if total(nymd eq [20040229,20040230,20040231,20040431,20040631,20040931,20041131,$
                        20050229,20050230,20050231,20050431,20050631,20050931,20051131,$
                        20060229,20060230,20060231,20060431,20060631,20060931,20061131,$
                        20070229,20070230,20070231,20070431,20070631,20070931,20071131,$
                        20080229,20080230,20080231,20080431,20080631,20080931,20081131,$
                        20090229,20090230,20090231,20090431,20090631,20090931,20091131,$
                        20100229,20100230,20100231,20100431,20100631,20100931,20101131,$
                        20110229,20110230,20110231,20110431,20110631,20110931,20111131,$
                        20120230,20120231,20120431,20120631,20120931,20121131,$
			20060228,20060301,20060302,20080928,20080929])$
                        eq 1.0 then continue
        filename = file_search('/z6/satellite/OMI/no2/OMI_Lok/'+Yr4+'/'+Yr4+'_'+Mon2+'_'+Day2+'_NO2TropCS30.hdf5')

        file_id=H5F_OPEN(filename)
        dataset_id_Latitude=H5D_OPEN(file_id,'/LATITUDE')
        Latitude=H5D_READ(dataset_id_Latitude)
        H5D_CLOSE,dataset_id_Latitude

        dataset_id_Longitude=H5D_OPEN(file_id,'/LONGITUDE')
        Longitude=H5D_READ(dataset_id_Longitude)
        H5D_CLOSE,dataset_id_Longitude

        dataset_id_ColumnAmountNO2Trop=H5D_OPEN(file_id,'/NO2.COLUMN.VERTICAL.TROPOSPHERIC.CS30_BACKSCATTER.SOLAR')
        ColumnAmountNO2Trop=H5D_READ(dataset_id_ColumnAmountNO2Trop)
        H5D_CLOSE,dataset_id_ColumnAmountNO2Trop

        no2_day = fltarr(nlon_g,nlat_g)

        For J = 0, nlat_g -1 do begin
                For I = 0,nlon_g-1 do begin
;			if ColumnAmountNO2Trop[I,J] ne -1.2676506E+30  then begin
                       if ColumnAmountNO2Trop[I,J] ge 0U  then begin
				no2_day[I,J]= ColumnAmountNO2Trop[I,J] /1E+15
				number[I,J] +=1
				no2[I,J] += no2_day[I,J] 
			endif

		endfor
	endfor
      endfor
    endfor


  For J = 0, nlat_g -1 do begin
	For I = 0,nlon_g-1 do begin
			if number[I,J] gt 0.0 then begin
				no2[I,J] = no2[I,J] /number[I,J] 
			endif else begin
				no2[I,J] =-999.0
			endelse
	endfor
  endfor
	

  ; reverse
  for j=1, nlat_g/2 do begin
        tmp = no2[*,j-1]
        no2[*,j-1] = no2[*,nlat_g-j]
        no2[*,nlat_g-j] = tmp
  endfor
  undefine, tmp

  header_output = [['ncols 3600'],['nrows 1800'],['xllcorner -180'],['yllcorner -90'],['cellsize 0.1'],['nodata_value -999.0']]
  outfile ='/home/liufei/Data/OMI_Lok/Result/'+Yr4+'_anual_Average_global_0.1X0.1.asc'
  openw,lun,outfile,/get_lun
  printf,lun,header_output,no2
  close,lun


  ;China=[15,72;55,136]
  nlon=640
  nlat=400
  no2_China = fltarr(nlon,nlat)
  no2_China= no2[(180+72)/0.1:(180+72)/0.1+nlon-1,(90-55)/0.1:(90-55)/0.1+nlat-1]

  header_output = [['ncols 640'],['nrows 400'],['xllcorner 72'],['yllcorner 15'],['cellsize 0.1'],['nodata_value -999.0']]
  outfile ='/home/liufei/Data/OMI_Lok/Result/'+Yr4+'_anual_Average_China_0.1X0.1.asc'
  openw,lun,outfile,/get_lun
  printf,lun,header_output,no2_China
  close,lun

endfor
end
