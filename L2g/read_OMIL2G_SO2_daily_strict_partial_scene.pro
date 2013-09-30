pro read_OMIL2G_SO2_daily_strict_partial_scene

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau

year=2012
;SET MODEL
InType   = CTM_Type( 'generic', Res=[ 0.125, 0.125 ], HalfPolar=0, Center180=0 )
InGrid   = CTM_Grid( InType, /No_Vertical )

;average = [SO2 yearly/seasonal mean, day number sum, yearly/sesonal sample number sum]
average = fltarr(InGrid.IMX,InGrid.JMX,4)
;***************************************
;set period
;***************************************
Period = 'JantoJun'
For month = 1, 6 do begin

	Yr4 = string(year,format='(i4.4)')
	Mon2 = string(month,format='(i2.2)')

	dir_omi='/z6/satellite/OMI/so2/NASA_Grid/v_2013_04_22/'+Yr4+'/'
	spawn,'ls '+dir_omi+'OMI-Aura_L2G-OMSO2G_'+Yr4+'m'+Mon2+'*.he5 ',filelist
	PRINT,'OMI FILES: '
	PRINT,filelist
	
        ;result = [SO2 monthly mean,month number sum, day number sum, monthly sample number sum]
        result=fltarr(InGrid.IMX,InGrid.JMX,4)

	for k=0, n_elements(filelist)-1 do begin

		infile = filelist(k)
		len = strlen(infile)
		print,infile

		filetag = strmid(infile,len-55,55)
		Yr4 = strmid(infile,len-35,4)
		Mon2 = strmid(infile,len-30,2)
		Day2 = strmid(infile,len-28,2)

		Outfile = '/home/liufei/Data/Satellite/SO2/NASA_L2g_tropCS30/'+Yr4+'/omi_so2_'+ Yr4 + Mon2 + Day2 +'_tropCS30.bpch'

		;GET DATE

		Year = Fix(Yr4) 
		Month = Fix(Mon2)
		Day = Fix(Day2)
		print,year,month,day
		Nymd = Year * 10000L + Month * 100L + Day
		tau0 = nymd2tau(Nymd)
		print,Nymd

		;----------------------------------------------------------------------
		; SET USER PARAMETERS HERE
		   filter = { maxsolarzenithangle: 70, $ ;filter out pixels on edges of swaths 
              		maxCloudFraction: 0.3,  $  ;Filter out cloudy pixels
              		rottenPixels: 1         $  ;Filter out rotten pixels (0-based)
            		}
		;----------------------------------------------------------------------


		IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

		fId = H5F_OPEN( Infile)
		if ( fId lt 0 ) then Message, 'Error opening file!'
                groupid = H5G_OPEN(fid,'/HDFEOS/GRIDS/OMI Total Column Amount SO2/Data Fields/')

	        dataId_1 = H5D_OPEN( groupid, "NumberOfCandidateScenes")
	        NumberOfCandidateScenes = H5D_READ(dataId_1)
	        help,NumberOfCandidateScenes
                H5D_CLOSE,dataId_1

		dataId_2 = H5D_OPEN( groupid, "CloudPressure")
		CloudPressure = H5D_READ(dataId_2)
		help,CloudPressure
		H5D_CLOSE,dataId_2

		dataId_3 = H5D_OPEN( groupid, "RadiativeCloudFraction")
		RadiativeCloudFraction = H5D_READ(dataId_3)
		;help,RadiativeCloudFraction
		H5D_CLOSE,dataId_3

		dataId_4 = H5D_OPEN( groupid, "SceneNumber")
		SceneNumber = H5D_READ(dataId_4)
		;help,SceneNumber
		H5D_CLOSE,dataId_4

		dataId_5 = H5D_OPEN( groupid, "SolarZenithAngle")
		SolarZenithAngle = H5D_READ(dataId_5)
		;help,SolarZenithAngle
		H5D_CLOSE,dataId_5

		dataId_6 = H5D_OPEN( groupid, "TerrainHeight")
		TerrainHeight = H5D_READ(dataId_6)
  ;		 help,TerrainHeight
		H5D_CLOSE,dataId_6

		dataId_7 = H5D_OPEN( groupid, "ColumnAmountSO2_PBL")
		so2pbl = H5D_READ(dataId_7)
   		;help,so2pbl
		H5D_CLOSE,dataId_7

		H5G_CLOSE,groupid

		H5F_CLOSE,fId 
;---------------------------------------------------------------------
; FILTER BEGINS HERE
;---------------------------------------------------------------------

		a_so2 = fltarr(InGrid.IMX,InGrid.JMX,8)
		a_sn = fltarr(InGrid.IMX,InGrid.JMX,8)
		so2 = fltarr(InGrid.IMX,InGrid.JMX)
		;sample is sample number
		sample = fltarr(InGrid.IMX,InGrid.JMX)

		For I =0, InGrid.IMX-1 do begin
		    For J =0, InGrid.JMX-1 do begin
   			For L = 0, 8-1 do begin 
			   a_so2[I,J,L] = -999.0
			   ncs = NumberOfCandidateScenes[I,J]
			   if (L ge ncs) then continue  
                           sn = SceneNumber[I,J,L]
			   if (sn lt 4) or (sn gt 25) then continue
			   sza = SolarZenithAngle[I,J,L]
			   if (sza gt 70) then continue
			   rcf = RadiativeCloudFraction[I,J,L] 
			   if (rcf gt 0.3) then continue
			   cp = CloudPressure[I,J,L]
			   if (cp gt 800) and (rcf gt 0.)then continue
			   th = TerrainHeight[I,J,L]
			   if (th gt 2000) then continue
			   a_so2[I,J,L] = so2pbl[I,J,L]
			   a_sn[I,J,L] = sn
			   if (a_so2[I,J,L] lt -10.0) or (a_so2[I,J,L] gt 10.0) then a_sn[I,J,L] = 0.0
   			Endfor
                        so2[I,J] = -999.0
			ind = where(a_sn[I,J,*] gt 0 )
			if (ind[0] gt -1) then begin 
				sample[I,J] = n_elements(ind)
				result[I,J,1]+=1
				result[I,J,2]+=sample[I,J]
				so2[I,J] = mean(a_so2[I,J,ind])
				result[I,J,0]+=so2[I,J]
			endif
		    Endfor
		Endfor
		

		; Make a DATAINFO structure
		success = CTM_Make_DataInfo( so2,             $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=26,              $
                                Tau0= tau0,             $
                                Unit='DU',              $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],$
                                /No_vertical )

		CTM_WriteBpch, ThisDataInfo, FileName = OutFile

	endfor
	
	For I =0, InGrid.IMX-1 do begin
        	For J =0, InGrid.JMX-1 do begin
		    if result[I,J,1] gt 0 then begin
		       result[I,J,0]= result[I,J,0]/ result[I,J,1]
		       average[I,J,0]+=result[I,J,0]
		       average[I,J,1]+=1
		       average[I,J,2]+=result[I,J,1]
		       average[I,J,3]+=result[I,J,2]
		    endif else begin
		       result[I,J,0]=-999.0
		    endelse
		endfor
	endfor
	
	VC = fltarr(InGrid.IMX, InGrid.JMX)
	VC = result[*,*,0]
	Day_num = fltarr(InGrid.IMX, InGrid.JMX)
	Day_num = result[*,*,1]
	Sample_num = fltarr(InGrid.IMX, InGrid.JMX)
	Sample_num = result[*,*,2]
	;output result
	;-----------------------------------------------------------------------
	; Write netCDF file
	;-----------------------------------------------------------------------
	Out_nc_file='/home/liufei/Data/Satellite/SO2/NASA_L2g_tropCS30/Monthly Mean/omi_so2_'+ Yr4 + Mon2 +'_tropCS30.nc'
	FileId = NCDF_Create( Out_nc_file, /Clobber )
	NCDF_Control, FileID, /NoFill
	xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
	yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
	LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
	LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
	VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
	DayID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
	SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
	NCDF_Attput, FileID, /Global, 'Title', 'monthly mean'
	NCDF_Control, FileID, /EnDef
	NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
	NCDF_VarPut, FileID, LatID, InGrid.YMID ,    Count=[ InGrid.JMX ]
	NCDF_VarPut, FileID, VCDID, VC,        Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_VarPut, FileID, DayID, Day_num,   Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_VarPut, FileID, SamID, Sample_num,Count=[ InGrid.IMX, InGrid.JMX ]
	NCDF_Close, FileID


endfor

For I =0, InGrid.IMX-1 do begin
	For J =0, InGrid.JMX-1 do begin
        	if average[I,J,1] gt 0 then begin
                       average[I,J,0]= average[I,J,0]/ average[I,J,1]
                endif else begin
                       average[I,J,0]=-999.0
                endelse
	endfor
endfor

VC = fltarr(InGrid.IMX, InGrid.JMX)
VC = average[*,*,0]
Month_num=fltarr(InGrid.IMX, InGrid.JMX)
Month_num=average[*,*,1]
Day_num = fltarr(InGrid.IMX, InGrid.JMX)
Day_num = average[*,*,2]
Sample_num = fltarr(InGrid.IMX, InGrid.JMX)
Sample_num = average[*,*,3]
;----------------------------------------------------------------------
; Write netCDF file
;-----------------------------------------------------------------------
Out_nc_file='/home/liufei/Data/Satellite/SO2/NASA_L2g_tropCS30/Monthly Mean/omi_so2_'+ Yr4 +'_'+ Period +'_tropCS30.nc'
FileId = NCDF_Create( Out_nc_file, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', InGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', InGrid.JMX  )
LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
MonID = NCDF_VarDef( FileID, 'MonthNumber',    [xID,yID], /Long  )
DayID = NCDF_VarDef( FileID, 'DayNumber',    [xID,yID], /Long  )
SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
NCDF_Attput, FileID, /Global, 'Title', 'period mean'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, LonID, InGrid.XMID ,   Count=[ InGrid.IMX ]
NCDF_VarPut, FileID, LatID, InGrid.YMID ,    Count=[ InGrid.JMX ]
NCDF_VarPut, FileID, VCDID, VC,        Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, MonID, Month_num,   Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, DayID, Day_num,   Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_VarPut, FileID, SamID, Sample_num,Count=[ InGrid.IMX, InGrid.JMX ]
NCDF_Close, FileID
end
