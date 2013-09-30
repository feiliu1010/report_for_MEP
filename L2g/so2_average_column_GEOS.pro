pro so2_average_column_GEOS

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0InGrid = CTM_Grid( InType )
InGrid = CTM_Grid( InType )
inxmid = InGrid.xmid
inymid = InGrid.ymid

;OutType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
;OutType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
OutType = CTM_Type( 'generic', Res=[ 2d0/3d0, 0.5d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

lat= fltarr(InGrid.JMX)
lon= fltarr(InGrid.IMX)
VC = fltarr(InGrid.IMX,InGrid.JMX)
;mon = fltarr(InGrid.IMX,InGrid.JMX)
day = fltarr(InGrid.IMX,InGrid.JMX)
sample = fltarr(InGrid.IMX,InGrid.JMX)

so2 = fltarr(OutGrid.IMX,OutGrid.JMX)
day2 =  fltarr(OutGrid.IMX,OutGrid.JMX)
sample2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

;period = '201304'
period = '2012_JantoJun'
infile = '/home/liufei/Data/Satellite/SO2/NASA_L2g_tropCS30/Monthly Mean/omi_so2_'+period+'_tropCS30.nc'

file_in = string(infile)
fid=NCDF_OPEN(file_in)
VCDID=NCDF_VARID(fid,'TropVCD')
NCDF_VARGET, fid, VCDID,VC
;MonID=NCDF_VARID(fid,'MonthNumber')
;NCDF_VARGET, fid, MonID,mon
DayID=NCDF_VARID(fid,'DayNumber')
NCDF_VARGET, fid,DayID,day
SamID=NCDF_VARID(fid,'SampleNumber')
NCDF_VARGET, fid,SamID,sample
latid=NCDF_VARID(fid,'LATITUDE')
NCDF_VARGET,fid,latid,lat
lonid=NCDF_VARID(fid,'LONGITUDE')
NCDF_VARGET,fid,lonid,lon
NCDF_CLOSE, fid

print, max(outxmid),min(outxmid)

file_in=strcompress(file_in, /REMOVE_ALL)
size = 0.3333
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    x = where( (inxmid[I] gt (outxmid - size)) and (inxmid[I] le (outxmid + size)))
    y = where( (inymid[J] gt (outymid - 0.25)) and (inymid[J] le (outymid + 0.25))) 
    if (VC[I,J] ge -10.0) then begin
       so2[x,y] += VC[I,J] 
       sample2[x,y] += sample[I,J]
       nod[x,y] += 1
       if day2[x,y] lt day[I,J] then begin
		day2[x,y]=day[I,J]
       endif
    endif
  endfor
endfor

CTM_Cleanup


for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  so2[I,J] /= nod[I,J]  $
        else  so2[I,J] = -999.0
  endfor
endfor

Out_nc_file='/home/liufei/Data/Satellite/SO2/NASA_L2g_tropCS30/Monthly Mean/omi_so2_'+ period +'_tropCS30_GEOS.nc'
FileId = NCDF_Create( Out_nc_file, /Clobber )
NCDF_Control, FileID, /NoFill
xID   = NCDF_DimDef( FileID, 'X', OutGrid.IMX )
yID   = NCDF_DimDef( FileID, 'Y', OutGrid.JMX  )
LonID = NCDF_VarDef( FileID, 'LONGITUDE',    [xID],     /Float )
LatID = NCDF_VarDef( FileID, 'LATITUDE',     [yID],     /Float )
VCDID = NCDF_VarDef( FileID, 'TropVCD',      [xID,yID], /Float )
nodID = NCDF_VarDef( FileID, 'DayNumber',   [xID,yID], /Long  )
SamID = NCDF_VarDef( FileID, 'SampleNumber', [xID,yID], /Long  )
NCDF_Attput, FileID, /Global, 'Title', 'period mean at 0.5*0.666'
NCDF_Control, FileID, /EnDef
NCDF_VarPut, FileID, LonID, OutGrid.XMID ,   Count=[ OutGrid.IMX ]
NCDF_VarPut, FileID, LatID, OutGrid.YMID ,   Count=[ OutGrid.JMX ]
NCDF_VarPut, FileID, VCDID, so2,    Count=[ OutGrid.IMX, OutGrid.JMX ]
NCDF_VarPut, FileID, nodID, day2,    Count=[ OutGrid.IMX, OutGrid.JMX ]
NCDF_VarPut, FileID, SamID, sample2,Count=[ OutGrid.IMX, OutGrid.JMX ]
NCDF_Close, FileID

end
