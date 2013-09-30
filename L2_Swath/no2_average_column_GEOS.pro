pro no2_average_column_GEOS

FORWARD_FUNCTION CTM_Grid, CTM_Type

;InType = CTM_Type( 'generic', Res=[ 2d0/3d0, 0.5d0], Halfpolar=0, Center180=0)
InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )
inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all

year = 2013
no2_sum = fltarr(InGrid.IMX,InGrid.JMX)
month_sum  = fltarr(InGrid.IMX,InGrid.JMX)
nod_sum = fltarr(InGrid.IMX,InGrid.JMX)
sample2_sum = fltarr(InGrid.IMX,InGrid.JMX)
period = 'JantoJun'

For month = 1, 6 do begin

	Yr4 = string(year,format='(i4.4)')
        Mon2 = string(month,format='(i2.2)')

	lat= fltarr(InGrid.JMX)
	lon= fltarr(InGrid.IMX)
	VC = fltarr(InGrid.IMX,InGrid.JMX)
	sample = fltarr(InGrid.IMX,InGrid.JMX)

	no2 = fltarr(InGrid.IMX,InGrid.JMX)
	sample2 = fltarr(InGrid.IMX,InGrid.JMX)
	nod = fltarr(InGrid.IMX,InGrid.JMX)

	dir_omi= '/home/liufei/Data/Satellite/NO2/L2S_GEO/'+Yr4+'/'
        spawn,'ls '+dir_omi+'OMI_0.66x0.50_'+Yr4+'_'+Mon2+'*.nc ',filelist
        PRINT,'OMI FILES: '
        PRINT,filelist

        for k=0, n_elements(filelist)-1 do begin
		infile = filelist(k)
		file_in = string(infile)
		fid=NCDF_OPEN(file_in)
		VCDID=NCDF_VARID(fid,'TropVCD')
		NCDF_VARGET, fid, VCDID,VC
		SamID=NCDF_VARID(fid,'SampleNumber')
		NCDF_VARGET, fid,SamID,sample
		latid=NCDF_VARID(fid,'LATITUDE')
		NCDF_VARGET,fid,latid,lat
		lonid=NCDF_VARID(fid,'LONGITUDE')
		NCDF_VARGET,fid,lonid,lon
		NCDF_CLOSE, fid


		for I = 0,InGrid.IMX-1 do begin
		  for J = 0,InGrid.JMX-1 do begin
    			if (VC[I,J] gt 0.0) then begin
			       no2[I,J] += VC[I,J] 
			       sample2[I,J] += sample[I,J]
			       nod[I,J] += 1
			endif
		  endfor
		endfor

		CTM_Cleanup
	endfor


	For I = 0,InGrid.IMX-1 do begin
	for J = 0,InGrid.JMX-1 do begin
	    if (nod[I,J] gt 0L) then begin
	    	no2[I,J] /= nod[I,J]  
		no2_sum[I,J]+= no2[I,J] 
		month_sum[I,J] += 1
		nod_sum[I,J]+= nod[I,J]
		sample2_sum[I,J] += sample2[I,J] 
	    endif else begin
		no2[I,J] = -999.0
	    endelse
	endfor
	endfor

	Out_nc_file='/home/liufei/Data/Satellite/NO2/L2S_GEO/Monthly Mean/'+Yr4+Mon2 +'_OMI_0.66x0.50.nc'
	FileId = NCDF_Create( Out_nc_file, /Clobber )
	NCDF_Control, FileID, /NoFill
	xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
	yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
	LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
	LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
	VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
	nodID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
	SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
	NCDF_Attput, FileID, /Global, 'Title', 'monthly mean at 0.5*0.666'
	NCDF_Control, FileID, /EnDef
	NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
	NCDF_VarPut, FileID, LatID, InGrid.YMID ,   Count=[ InGrid.JMX ]
	NCDF_VarPut, FileID, VCDID, no2,    Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_VarPut, FileID, nodID, nod,    Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_VarPut, FileID, SamID, sample2,Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_Close, FileID
endfor	

For I = 0,InGrid.IMX-1 do begin
	for J = 0,InGrid.JMX-1 do begin
            if (month_sum[I,J] gt 0L)             $
            then  no2_sum[I,J] /= month_sum[I,J]  $
            else  no2_sum[I,J] = -999.0
        endfor
endfor


Out_nc_file='/home/liufei/Data/Satellite/NO2/L2S_GEO/Monthly Mean/'+Yr4+'_'+period +'_OMI_0.66x0.50.nc'
FileId = NCDF_Create( Out_nc_file, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
MonID = NCDF_VarDef( FileID, 'MonthNumber',  [xID,yID], /Long  )
nodID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
NCDF_Attput, FileID, /Global, 'Title', 'period mean at 0.5*0.666'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
NCDF_VarPut, FileID, LatID, InGrid.YMID ,   Count=[ InGrid.JMX ]
NCDF_VarPut, FileID, VCDID, no2_sum,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, MonID, month_sum,  Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, nodID, nod_sum,    Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, SamID, sample2_sum,Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_Close, FileID


end
