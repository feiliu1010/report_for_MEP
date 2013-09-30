pro no2_china_density

;nlon_g=2880/2
;nlat_g=1440/2

;global = fltarr(nlon_g,nlat_g)

nlon = 256
nlat = 160
;china density,[72,15,136,55]
emis = fltarr(nlon,nlat)
provcode = fltarr(nlon,nlat)
;nlon_s = (72+180)/0.25
;nlat_s = (90-55)/0.25
;mask shows the background data
mask = fltarr(nlon,nlat)
;provcode_r is used to get the list of adcode
provcode_r = fltarr(nlon,nlat)
header_p = strArr(1,6)
filename_map = '/home/liufei/r5/report_for_MEP/provcode_25.asc'
openr,lun,filename_map,/get_lun
readf,lun,header_p,provcode
close,/all
;print,provcode[0,0],header_p
provcode_r = provcode
provcode_r=provcode_r[sort(provcode_r)]
;number is the number of province + 999
N =Uniq(provcode_r)
number = N_Elements(N)
;num is used for save the adcode
num = fltarr(number)
num = provcode_r[N]
undefine,N
;print,number,num
;the sequence of area name = [none,Beijing,Tianjin,Hebei,Shanxi,Neimengg,Liaoning,Jilin,Heilongjiang,Shanghai,Jiangsu,Zhejiang,Anhui,Fujian,Jiangxi,Shandong,Henan,Hubei,Hunan,Guangdong,Guangxi,Hainan,Chongqing,Sichuan,Guizhou,Yunnan,Xizang,Shaanxi,Gansu,Qinghai,Ningxia,Xinjiang]
;china density by province,[adcode,sample number,average]
;emis2 = fltarr(number,3)

headermask = strarr(1,6)
filename_mask = '/home/liufei/Data/Satellite/NO2/trend/mask_no2_le_1.0_0.25X0.25.asc'
openr,lun,filename_mask,/get_lun
readf,lun,headermask,mask
close,/all


For year = 2010,2012 do begin
	emis2 = fltarr(number,3)
	header = strarr(1,6)
	Yr4 = string(year,format='(i4.4)')
	filename = '/home/liufei/r5/report_for_MEP/Data/NO2/NASA_L2g/'+Yr4+'_Jan2Sep_Average_China_0.25X0.25.asc'
	openr,lun,filename,/get_lun
	readf,lun,header,emis
	print,Yr4
	
	emis[where (emis ge 0.0)] = emis[where (emis ge 0.0)]/(10.0^15)
;	emis = global[nlon_s:nlon_s+nlon-1,nlat_s:nlat_s+nlat-1]
	;filter the data which yearly mean <=1(background)
        loc = where(mask eq -999.0)
        emis[loc]=-999.0
	undefine,loc
	For i=0,number-1 do begin
		emis2[i,0]= num[i]
		P = Where((provcode eq  num[i]) and ( emis ge 0.0 ) )
		if ( P[0] eq -1 ) then begin
		print,'no data',Yr4,i
		endif else begin
		emis2[i,1]+= N_Elements(P)
		emis2[i,2]+= Total(emis[P])	
		endelse
		undefine,P
	endfor
	close,/all
	free_lun,lun

 
	For i=0,number-1 do begin
	if emis2[i,1] gt 0.0 then begin
		emis2[i,2]= emis2[i,2]/emis2[i,1]
	endif else begin
		emis2[i,2]= -999.0
	endelse
	endfor

	outfile = '/home/liufei/r5/report_for_MEP/Data/NO2/NASA_L2g/province/no2_'+Yr4+'province_Jan2Sep_average.asc'
	;output emis2 = [emis,provcode]
	openw,lun,outfile,/get_lun
	printf,lun,emis2
	close,lun

endfor

end



