pro regrid_monthly_satellite_test

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
;OutType = CTM_Type( 'generic', Res=[ 1.0d0, 1.0d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

for year = 2011,2011 do begin
for Month = 7,12 do begin
;for Day =1,31 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
;Day2 = string( Day, format = '(i2.2)')
;nymd = Year * 10000L + Month * 100L + Day * 1L
;Tau0 = nymd2tau(NYMD)
;nymd = year*10000L+1*100L+1L
nymd = Year * 10000L + Month * 100L +  1L
tau0 = nymd2tau(nymd)
print,nymd

;if (nymd eq 20060228) then continue
;if (nymd eq 20060229) then continue
;if (nymd eq 20060230) then continue
;if (nymd eq 20060231) then continue
;if (nymd eq 20060301) then continue
;if (nymd eq 20060302) then continue
;if (nymd eq 20060431) then continue
;if (nymd eq 20060631) then continue
;if (nymd eq 20060931) then continue
;if (nymd eq 20061131) then continue

no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)


;infile = '/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_'+ Yr4+'_annual_average.bpch'
;infile = '/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_'+ Yr4+'_Jan2Jun_average.bpch'
infile = '/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_'+ Yr4+Mon2+'.bpch'


CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1,tau0=tau0, filename = infile
data18 = *(datainfo1[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    x = where( (inxmid[I] gt (outxmid - 0.25)) and (inxmid[I] le (outxmid + 0.25)))
    y = where( (inymid[J] gt (outymid - 0.25)) and (inymid[J] le (outymid + 0.25)))
   ; x = where( (inxmid[I] gt (outxmid - 0.5)) and (inxmid[I] le (outxmid + 0.5)))
   ; y = where( (inymid[J] gt (outymid - 0.5)) and (inymid[J] le (outymid + 0.5)))


    if (data18[I,J] gt 0) then begin
        no2 [x,y] += data18[I,J]
        nod [x,y] += 1
    endif
  endfor
endfor

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = -999.0
  endfor
endfor


;Outfile ='/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_KNMI_L3_V2.0_'+ Yr4+'_annual_average_1X1.bpch'
;Outfile ='/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_KNMI_L3_V2.0_'+ Yr4+'_Jan2Jun_average_05X05.bpch'
;Outfile ='/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_KNMI_L3_V2.0_'+ Yr4+'_Jan2Jun_average_1X1.bpch'
Outfile ='/z4/liufei/Satellite/NO2/KNMI_L3_V2.0/'+'no2_KNMI_L3_V2.0_'+ Yr4+Mon2+'_05X05.bpch'


 
  success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,              $
                                Tau0= tau0,             $
                                Unit='E+15molec/cm2',   $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

    CTM_WriteBpch, ThisDataInfo, FileName = OutFile
    CTM_Cleanup

;endfor

endfor
endfor
end
