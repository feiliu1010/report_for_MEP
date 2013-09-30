pro so2_7day_smooth_region_average

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data

InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid
close, /all

limit = [30,110,40,123]

i_index = where(xmid ge limit[1] and xmid le limit[3])
j_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i_index, max = I2)
J1 = min(j_index, max = J2)

x0 = I2-I1+1
y0 = J2-J1+1

year = 2012
yr4  = String( year, format = '(i4.4)' )
result = fltarr(2,365)

num = 0

for m = 0,2 do begin
for d = 0,31-1 do begin

month = m+1
day = d+1
mon2 = string(month, format='(i2.2)')
day2 = string(day, format='(i2.2)')

nymd0 = year*10000L+month*100L+day*1L
print,nymd0
tau0 = nymd2tau(nymd0)

if (nymd0 eq 20050229) then continue
if (nymd0 eq 20050230) then continue
if (nymd0 eq 20050231) then continue
if (nymd0 eq 20050431) then continue
if (nymd0 eq 20050631) then continue
if (nymd0 eq 20050931) then continue
if (nymd0 eq 20051131) then continue
if (nymd0 eq 20060229) then continue
if (nymd0 eq 20060230) then continue
if (nymd0 eq 20060231) then continue
if (nymd0 eq 20060431) then continue
if (nymd0 eq 20060631) then continue
if (nymd0 eq 20060931) then continue
if (nymd0 eq 20061131) then continue
if (nymd0 eq 20070229) then continue
if (nymd0 eq 20070230) then continue
if (nymd0 eq 20070231) then continue
if (nymd0 eq 20070431) then continue
if (nymd0 eq 20070631) then continue
if (nymd0 eq 20070931) then continue
if (nymd0 eq 20071131) then continue
if (nymd0 eq 20080230) then continue
if (nymd0 eq 20080231) then continue
if (nymd0 eq 20080431) then continue
if (nymd0 eq 20080631) then continue
if (nymd0 eq 20080931) then continue
if (nymd0 eq 20081131) then continue
if (nymd0 eq 20090229) then continue
if (nymd0 eq 20090230) then continue
if (nymd0 eq 20090231) then continue
if (nymd0 eq 20090431) then continue
if (nymd0 eq 20090631) then continue
if (nymd0 eq 20090931) then continue
if (nymd0 eq 20091131) then continue
if (nymd0 eq 20100229) then continue
if (nymd0 eq 20100230) then continue
if (nymd0 eq 20100231) then continue
if (nymd0 eq 20100431) then continue
if (nymd0 eq 20100631) then continue
if (nymd0 eq 20100931) then continue
if (nymd0 eq 20101131) then continue
if (nymd0 eq 20110229) then continue
if (nymd0 eq 20110230) then continue
if (nymd0 eq 20110231) then continue
if (nymd0 eq 20110431) then continue
if (nymd0 eq 20110631) then continue
if (nymd0 eq 20110931) then continue
if (nymd0 eq 20111131) then continue
if (nymd0 eq 20120229) then continue
if (nymd0 eq 20120230) then continue
if (nymd0 eq 20120231) then continue
if (nymd0 eq 20120431) then continue
if (nymd0 eq 20120631) then continue
if (nymd0 eq 20120931) then continue
if (nymd0 eq 20121131) then continue



julday_now = double(julday(month,day,year,0,0,0))

caldat,(julday_now-1),MM1,DD1,YY1,HH1
caldat,(julday_now-2),MM2,DD2,YY2,HH2
caldat,(julday_now-3),MM3,DD3,YY3,HH3
caldat,(julday_now-4),MM4,DD4,YY4,HH4
caldat,(julday_now-5),MM5,DD5,YY5,HH5
caldat,(julday_now-6),MM6,DD6,YY6,HH6

nymd1 = YY1*10000L+MM1*100L+DD1
nymd2 = YY2*10000L+MM2*100L+DD2
nymd3 = YY3*10000L+MM3*100L+DD3
nymd4 = YY4*10000L+MM4*100L+DD4
nymd5 = YY5*10000L+MM5*100L+DD5
nymd6 = YY6*10000L+MM6*100L+DD6

tau1 = nymd2tau(nymd1)
tau2 = nymd2tau(nymd2)
tau3 = nymd2tau(nymd3)
tau4 = nymd2tau(nymd4)
tau5 = nymd2tau(nymd5)
tau6 = nymd2tau(nymd6)

dir_data = '/z3/wangsiwen/Satellite/so2/NASA_L2G/so2_for_mep/'

infile0 = dir_data+Yr4+'/'+Mon2+'/omi_so2_'+strtrim(string(nymd0),2)+'.bpch'
infile1 = dir_data+strtrim(string(YY1),2)+'/'+string(MM1,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd1),2)+'.bpch'
infile2 = dir_data+strtrim(string(YY2),2)+'/'+string(MM2,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd2),2)+'.bpch'
infile3 = dir_data+strtrim(string(YY3),2)+'/'+string(MM3,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd3),2)+'.bpch'
infile4 = dir_data+strtrim(string(YY4),2)+'/'+string(MM4,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd4),2)+'.bpch'
infile5 = dir_data+strtrim(string(YY5),2)+'/'+string(MM5,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd5),2)+'.bpch'
infile6 = dir_data+strtrim(string(YY6),2)+'/'+string(MM6,format='(i2.2)')+'/omi_so2_'+strtrim(string(nymd6),2)+'.bpch'

CTM_Cleanup

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 26, tau0 = tau0, filename = infile0
data18 = *(datainfo1[0].data)

CTM_Get_Data, datainfo2, 'IJ-AVG-$', tracer = 26, tau0 = tau1, filename = infile1
data28 = *(datainfo2[0].data)

CTM_Get_Data, datainfo3, 'IJ-AVG-$', tracer = 26, tau0 = tau2, filename = infile2
data38 = *(datainfo3[0].data)

CTM_Get_Data, datainfo4, 'IJ-AVG-$', tracer = 26, tau0 = tau3, filename = infile3
data48 = *(datainfo4[0].data)

CTM_Get_Data, datainfo5, 'IJ-AVG-$', tracer = 26, tau0 = tau4, filename = infile4
data58 = *(datainfo5[0].data)

CTM_Get_Data, datainfo6, 'IJ-AVG-$', tracer = 26, tau0 = tau5, filename = infile5
data68 = *(datainfo6[0].data)

CTM_Get_Data, datainfo7, 'IJ-AVG-$', tracer = 26, tau0 = tau6, filename = infile6
data78 = *(datainfo7[0].data)

data818=data18[I1:I2,J1:J2]
data828=data28[I1:I2,J1:J2]
data838=data38[I1:I2,J1:J2]
data848=data48[I1:I2,J1:J2]
data858=data58[I1:I2,J1:J2]
data868=data68[I1:I2,J1:J2]
data878=data78[I1:I2,J1:J2]

so2 = 0.0
nod = 0L

for x = 0,x0-1 do begin
  for y = 0,y0-1 do begin
    if (data818[x,y] ge -10.0) then begin
       so2 += data818[x,y] 
       nod += 1
    endif
    if (data828[x,y] ge -10.0) then begin
       so2 += data828[x,y]
       nod += 1
    endif
    if (data838[x,y] ge -10.0) then begin
       so2 += data838[x,y] 
       nod += 1
    endif
    if (data848[x,y] ge -10.0) then begin
       so2 += data848[x,y]
       nod += 1
    endif
    if (data858[x,y] ge -10.0) then begin
       so2 += data858[x,y]
       nod += 1
    endif
    if (data868[x,y] ge -10.0) then begin
       so2 += data868[x,y]
       nod += 1
    endif
    if (data878[x,y] ge -10.0) then begin
       so2 += data878[x,y]
       nod += 1
    endif
  endfor
endfor

if (nod gt 0L) then so2 /= nod
result[0,num]=so2
result[1,num]=long(nymd0-year*10000L)
num++

endfor
endfor

outfile = 'so2_7day_smooth_region_average_'+Yr4+'.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, result, 'so2', $
           Longname='SO2 columns',$
           Unit='DU', $
           FILL=-999.0

HDF_SD_End, FID

end

