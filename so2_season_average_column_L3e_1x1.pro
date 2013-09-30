pro so2_season_average_column_L3e_1x1,year,season

for year=2008,2009 do begin
;year=2012
season='annual'
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 1d0, 1d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

year0 = year
Yr40  = String( year0, format = '(i4.4)' )
season3 = strtrim(season,2)

so2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

case season3 of
;'MAM': month=[3,4,5] 
;'JJA': month=[6,7,8]
;'SON': month=[9,10,11]
;'DJF': month=[12,1,2]
'annual':month=[1,2,3,4,5,6,7,8,9,10,11,12]
'JantoMar': month=[1,2,3]
'JantoJun': month=[1,2,3,4,5,6]
'AprtoJun': month=[4,5,6]
'JultoSep': month=[7,8,9]
'OcttoDec': month=[10,11,12]
else: break
endcase

;for m = 0,5 do begin
for m=0,11 do begin

mon2 = string(month[m], format='(i2.2)')
year = year0
;if (month[m] eq 12) then year = year0 - 1L
Yr4  = String( Year, format = '(i4.4)' )

for d = 0,31-1 do begin

day2 = string(d+1, format='(i2.2)')
nymd = year*10000L+month[m]*100L+(d+1)*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20060228) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20080928) then continue
if (nymd eq 20080929) then continue


if (nymd eq 20050229) then continue
if (nymd eq 20050230) then continue
if (nymd eq 20050231) then continue
if (nymd eq 20050431) then continue
if (nymd eq 20050631) then continue
if (nymd eq 20050931) then continue
if (nymd eq 20051131) then continue
if (nymd eq 20060229) then continue
if (nymd eq 20060230) then continue
if (nymd eq 20060231) then continue
if (nymd eq 20060431) then continue
if (nymd eq 20060631) then continue
if (nymd eq 20060931) then continue
if (nymd eq 20061131) then continue
if (nymd eq 20070229) then continue
if (nymd eq 20070230) then continue
if (nymd eq 20070231) then continue
if (nymd eq 20070431) then continue
if (nymd eq 20070631) then continue
if (nymd eq 20070931) then continue
if (nymd eq 20071131) then continue
if (nymd eq 20080230) then continue
if (nymd eq 20080231) then continue
if (nymd eq 20080431) then continue
if (nymd eq 20080631) then continue
if (nymd eq 20080931) then continue
if (nymd eq 20081131) then continue
if (nymd eq 20090229) then continue
if (nymd eq 20090230) then continue
if (nymd eq 20090231) then continue
if (nymd eq 20090431) then continue
if (nymd eq 20090631) then continue
if (nymd eq 20090931) then continue
if (nymd eq 20091131) then continue

if (nymd eq 20100229) then continue
if (nymd eq 20100230) then continue
if (nymd eq 20100231) then continue
if (nymd eq 20100431) then continue
if (nymd eq 20100631) then continue
if (nymd eq 20100931) then continue
if (nymd eq 20101131) then continue
if (nymd eq 20110229) then continue
if (nymd eq 20110230) then continue
if (nymd eq 20110231) then continue
if (nymd eq 20110431) then continue
if (nymd eq 20110631) then continue
if (nymd eq 20110931) then continue
if (nymd eq 20111131) then continue
if (nymd eq 20120229) then continue
if (nymd eq 20120230) then continue
if (nymd eq 20120231) then continue
if (nymd eq 20120431) then continue
if (nymd eq 20120631) then continue
if (nymd eq 20120931) then continue
if (nymd eq 20121131) then continue

;infile = '/z3/wangsiwen/Satellite/so2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr4+mon2+day2+'_v003.bpch'
infile ='/z4/liufei/Satellite/SO2/OMI_L3e_bpch/OMI-Aura_L3-OMSO2e_'+Yr4+mon2+day2+'_v003.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 26, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)
CTM_Cleanup

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    ;x = where( (inxmid[I] gt (outxmid - 0.25)) and (inxmid[I] le (outxmid + 0.25)))
    ;y = where( (inymid[J] gt (outymid - 0.25)) and (inymid[J] le (outymid + 0.25))) 
    x = where( (inxmid[I] gt (outxmid - 0.5)) and (inxmid[I] le (outxmid + 0.5)))
    y = where( (inymid[J] gt (outymid - 0.5)) and (inymid[J] le (outymid + 0.5)))

    if (data18[I,J] ge -10.0) then begin
       so2[x,y] += data18[I,J] 
       nod[x,y] += 1
    endif
  endfor
endfor

endfor
endfor

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  so2[I,J] /= nod[I,J]  $
        else  so2[I,J] = -999.0
  endfor
endfor


;outfile = '/home/wangsiwen/outdir/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr40+'_'+season3+'_v003.05x05.bpch'
outfile ='/z4/liufei/Satellite/SO2/OMI_L3e_bpch_average/OMI-Aura_L3-OMSO2e_'+Yr40+'_'+season3+'_v003.1x1.bpch'

   success = CTM_Make_DataInfo( so2,                    $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=26,              $
                                Tau0= tau0,             $
                                Unit='DU',              $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   success = CTM_Make_DataInfo( nod,                    $
                                ThisDataInfo2,          $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=88,              $
                                Tau0= tau0,             $
                                Unit='unitless',        $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   NewDataInfo = [ThisDataInfo, ThisDataInfo2]

   CTM_WriteBpch, NewDataInfo, FileName = OutFile

print,outfile

endfor
end
