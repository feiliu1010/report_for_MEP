pro no2_column_region_average_knmi

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

;InType_1 = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InGrid_1 = CTM_Grid( InType_1 )

;xmid_1 = InGrid_1.xmid
;ymid_1 = InGrid_1.ymid

InType_2 = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
InGrid_2 = CTM_Grid( InType_2 )

xmid_2 = InGrid_2.xmid
ymid_2 = InGrid_2.ymid

close, /all

;limit = [30,110,40,123] & tag = 'CEC_extend'
;limit = [36,103,40,107.5] & tag = 'Ningxia'
;limit = [25,102.3333,31.75,107.6667] & tag = 'Sichuan'
;limit = [27.25,111.5,30,113.75] & tag = 'Changsha'
;limit = [24,117.25,25.5,119.75] & tag = 'Fujian'
;limit2 = [25.5,118.5,26.75,119.75] ; for Fujian
limit = [21.5,112,24,114.6667] & tag = 'PRD'

;i_index1 = where(xmid_1 ge limit[1] and xmid_1 le limit[3])
;j_index1 = where(ymid_1 ge limit[0] and ymid_1 le limit[2])
;I11 = min(i_index1, max = I12)
;J11 = min(j_index1, max = J12)

i_index2 = where(xmid_2 ge limit[1] and xmid_2 le limit[3])
j_index2 = where(ymid_2 ge limit[0] and ymid_2 le limit[2])
I21 = min(i_index2, max = I22)
J21 = min(j_index2, max = J22)

;x1 = I12-I11+1 & y1 = J12-J11+1
x2 = I22-I21+1 & y2 = J22-J21+1

;i_index1 = where(xmid_1 ge limit2[1] and xmid_1 le limit2[3])
;j_index1 = where(ymid_1 ge limit2[0] and ymid_1 le limit2[2])
;Iv11 = min(i_index1, max = Iv12)
;Jv11 = min(j_index1, max = Jv12)

;i_index2 = where(xmid_2 ge limit2[1] and xmid_2 le limit2[3])
;j_index2 = where(ymid_2 ge limit2[0] and ymid_2 le limit2[2])
;Iv21 = min(i_index2, max = Iv22)
;Jv21 = min(j_index2, max = Jv22)

;x3 = Iv12-Iv11+1 & y3 = Jv12-Jv11+1
;x4 = Iv22-Iv21+1 & y4 = Jv22-Jv21+1

;result1 = fltarr(2,84)
result2 = fltarr(2,8)
num = 0L

;Season = 'Jan2Mar'
;Season = 'Jan2Jun'
;Season = 'Jan2Sep'
;Season = 'annual'
Season = 'Jan2May'
for year = 2007,2013 do begin

yr4  = String( year, format = '(i4.4)' )

nymd0 = year*10000L+1*100L+1L
print,nymd0
tau0 = nymd2tau(nymd0)


dir_data2 ='/home/liufei/Data/Satellite/NO2/KNMI_L3/'
infile2 = dir_data2+'no2_'+Yr4+'_'+Season+'_average.bpch'

;CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile1
;data18 = *(datainfo1[0].data)

CTM_Get_Data, datainfo2, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile2
data28 = *(datainfo2[0].data)

CTM_Cleanup

;data818=data18[I11:I12,J11:J12]
data828=data28[I21:I22,J21:J22]
;data838=data18[Iv11:Iv12,Jv11:Jv12]
;data848=data28[Iv21:Iv22,Jv21:Jv22]

no2_1 = 0.0 & no2_2 = 0.0
nod_1 = 0L & nod_2 = 0L

;for x = 0,x1-1 do begin
 ; for y = 0,y1-1 do begin
   ; if (data818[x,y] gt 0.0) then begin
    ;   no2_1 += data818[x,y] 
      ; nod_1 += 1
   ; endif
;endfor
;endfor

for x = 0,x2-1 do begin
  for y = 0,y2-1 do begin
    if (data828[x,y] gt 0.0) then begin
       no2_2 += data828[x,y]
       nod_2 += 1
    endif
endfor
endfor

;for x = 0,x3-1 do begin
;  for y = 0,y3-1 do begin
;    if (data838[x,y] gt 0.0) then begin
;       no2_1 += data838[x,y]
;       nod_1 += 1
;    endif
;endfor
;endfor

;for x = 0,x4-1 do begin
;  for y = 0,y4-1 do begin
;    if (data848[x,y] gt 0.0) then begin
;       no2_2 += data848[x,y]
;       nod_2 += 1
;    endif
;endfor
;endfor

;if (nod_1 gt 0L) then no2_1 /= nod_1
if (nod_2 gt 0L) then no2_2 /= nod_2

;result1[0,num]=long(nymd0-year*10000L)
;result1[1,num]=no2_1
result2[0,num]=long(nymd0-year*10000L)
result2[1,num]=no2_2
num++

endfor

outfile = 'no2_7year_'+Season+'_column_'+tag+'_region_average.hdf'
;outfile = 'no2_7year_annual_column_'+tag+'_region_average.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

;HDF_SETSD, FID, result1, 'NASA_no2', $
          ; Longname='NO2 columns',$
          ; Unit='1.0E+15 molec/cm2', $
          ; FILL=-999.0

HDF_SETSD, FID, result2, 'KNMI_no2', $
           Longname='NO2 columns',$
           Unit='1.0E+15 molec/cm2', $
           FILL=-999.0

HDF_SD_End, FID

end

