pro so2_column_region_average

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

InType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

;limit = [30,110,40,123] & tag = 'CEC_extend'
;limit = [36,103,40,107.5] & tag = 'Ningxia'
limit = [25,102.3333,31.75,107.6667] & tag = 'Sichuan'
;limit = [24,117.25,25.5,119.75] & tag = 'Fujian'
;limit2 = [25.5,118.5,26.75,119.75]
;limit = [27.25,111.5,30,113.75] & tag = 'Changsha'
;limit = [21.5,112,24,114.6667] & tag = 'PRD'


i_index = where(xmid ge limit[1] and xmid le limit[3])
j_index = where(ymid ge limit[0] and ymid le limit[2])
I11 = min(i_index, max = I12)
J11 = min(j_index, max = J12)

x1 = I12-I11+1 & y1 = J12-J11+1

;i_index = where(xmid ge limit2[1] and xmid le limit2[3])
;j_index = where(ymid ge limit2[0] and ymid le limit2[2])
;Iv11 = min(i_index, max = Iv12)
;Jv11 = min(j_index, max = Jv12)

;x2 = Iv12-Iv11+1 & y2 = Jv12-Jv11+1

result = fltarr(2,8)
num = 0L

;Season = 'JantoMar'
Season = 'JantoJun'
;Season = 'annual'
;Season = 'JantoSep'
;Season='JantoMay'
for year = 2007,2013 do begin

yr4  = String( year, format = '(i4.4)' )

nymd0 = year*10000L+1*100L+1L
print,nymd0
tau0 = nymd2tau(nymd0)

infile='/home/liufei/Data/Satellite/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr4+'_'+Season+'_v003.05x05.bpch'
;infile ='/z4/liufei/Satellite/SO2/OMI_L3e_bpch_average/OMI-Aura_L3-OMSO2e_'+Yr4+'_'+Season+'_v003.05x05.bpch'
CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 26, filename = infile
data18 = *(datainfo1[0].data)

CTM_Cleanup

data818=data18[I11:I12,J11:J12]
;data828=data18[Iv11:Iv12,Jv11:Jv12]

so2 = 0.0
nod = 0L

for x = 0,x1-1 do begin
  for y = 0,y1-1 do begin
    if (data818[x,y] gt -10.0) then begin
       so2 += data818[x,y] 
       nod += 1
    endif
endfor
endfor

;for x = 0,x2-1 do begin
;  for y = 0,y2-1 do begin
;    if (data828[x,y] gt -10.0) then begin
;       so2 += data828[x,y]
;       nod += 1
;    endif
;endfor
;endfor

if (nod gt 0L) then so2 /= nod

result[0,num]=long(nymd0-year*10000L)
result[1,num]=so2
num++

endfor

outfile = 'so2_OMIL3e_7year_'+Season+'_column_'+tag+'_region_average.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, result, 'NASA_so2', $
           Longname='SO2 columns',$
           Unit='DU', $
           FILL=-999.0

HDF_SD_End, FID

end

