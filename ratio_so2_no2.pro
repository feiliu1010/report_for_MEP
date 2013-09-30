pro ratio_so2_no2

for year=2010,2011 do begin
season='JantoSep'
FORWARD_FUNCTION CTM_Grid,CTM_Type,CTM_Get_Data,CTM_Writebpch

InType = CTM_Type('generic',Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType)

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type('generic',Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType)

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close,/all

year1=year+1
Yr4 = string(year, format = '(i4.4)')
Yr41 = string(year1,format = '(i4.4)')
;so2 and no2 stands for ratio
so2 = fltarr(OutGrid.IMX,OutGrid.JMX)
no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
ratio = fltarr(OutGrid.IMX,OutGrid.JMX)

nymd = year*10000L+100L+1L
print,nymd
tau0 = nymd2tau(nymd)

infile_SO2_1='/home/liufei/r5/IDL/report_for_MEP/Data/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr4+'_'+season+'_v003.05x05.bpch'
infile_SO2_2='/home/liufei/r5/IDL/report_for_MEP/Data/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr41+'_'+season+'_v003.05x05.bpch'
infile_NO2_1='/home/liufei/r5/IDL/report_for_MEP/Data/NO2/KNMI_L3/no2_'+Yr4+'_'+season+'_average_05x05.bpch'
infile_NO2_2='/home/liufei/r5/IDL/report_for_MEP/Data/NO2/KNMI_L3/no2_'+Yr41+'_'+season+'_average_05x05.bpch'

CTM_Get_Data,datainfo_SO2_1,'IJ-AVG-$',tracer= 26, filename = infile_SO2_1
data_SO2_1 = *(datainfo_SO2_1[0].data)
CTM_Cleanup

CTM_Get_Data,datainfo_SO2_2,'IJ-AVG-$',tracer= 26, filename = infile_SO2_2
data_SO2_2 = *(datainfo_SO2_2[0].data)
CTM_Cleanup

CTM_Get_Data,datainfo_NO2_1,'IJ-AVG-$',tracer= 1, filename = infile_NO2_1
data_NO2_1 = *(datainfo_NO2_1[0].data)
CTM_Cleanup

CTM_Get_Data,datainfo_NO2_2,'IJ-AVG-$',tracer= 1, filename = infile_NO2_2
data_NO2_2 = *(datainfo_NO2_2[0].data)
CTM_Cleanup

for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
      if ((data_SO2_1[I,J] gt 0.0) and (data_SO2_2[I,J] gt 0.0)) then begin 
          so2[I,J]=data_SO2_2[I,J]/data_SO2_1[I,J]
      ;print,data_SO2_1[I,J],so2[I,J]
      endif else begin so2[I,J]= 1.0
      endelse 
    endfor
endfor

for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
        if (so2[I,J] gt 5) then begin
                  so2[I,J]=1.0
        endif 
      print, so2[I,J]
    endfor
endfor

for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
      if ((data_NO2_1[I,J] gt 0.0) and (data_NO2_2[I,J] gt 0.0)) then begin
           no2[I,J]=data_NO2_2[I,J]/data_NO2_1[I,J]
      endif else begin no2[I,J]= 1.0
      endelse
    endfor
endfor

for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
        if (no2[I,J] gt 5) then begin
                   no2[I,J]=1.0
        endif
      print, no2[I,J]
    endfor
endfor


for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
       if ((so2[I,J] gt 0.0) and (no2[I,J] gt 0.0)) then begin 
           ratio[I,J]= no2[I,J]/so2[I,J]
       endif else begin  ratio[I,J]= 1.0
    endelse
endfor
endfor

outfile ='/home/liufei/r5/IDL/report_for_MEP/result/201201_201209/OMI-L3-NO2_SO2_ratio_'+Yr41+'_05x05.bpch'


success = CTM_Make_DataInfo (so2,$
                             ThisDataInfo1,$
			     ThisFileInfo1,$
			     ModelInfo=InType,$
		 	     GridInfo=InGrid,$
			     DiagN='IJ-AVG-$',$
			     Tracer =1,$
                             Tau0=tau0,$
			     Unit='unitless',$
                             Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                             First=[1L,1L,1L],$
                             /No_vertical)

success = CTM_Make_DataInfo (no2,$
                             ThisDataInfo2,$
			      ThisFileInfo2,$
                             ModelInfo=InType,$
                             GridInfo=InGrid,$
                             DiagN='IJ-AVG-$',$
                             Tracer =1,$
                             Tau0=tau0,$
                             Unit='unitless',$
                             Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                             First=[1L,1L,1L],$
                             /No_vertical)

success = CTM_Make_DataInfo (ratio,$
                             ThisDataInfo3,$
			      ThisFileInfo3,$
                             ModelInfo=InType,$
                             GridInfo=InGrid,$
                             DiagN='IJ-AVG-$',$
                             Tracer =1,$
                             Tau0=tau0,$
                             Unit='unitless',$
                             Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                             First=[1L,1L,1L],$
                             /No_vertical)

;NewDataInfo = [[[ThisDataInfo1],ThisDataInfo2],ThisDataInfo3]
;NewFileInfo = [[[ThisFileInfo1], ThisFileInfo2], ThisFileInfo3]

NewDataInfo = [ ThisDataInfo3]
NewFileInfo = [ ThisFileInfo3]
CTM_WriteBpch,NewDataInfo, NewFileInfo,FileName = OutFile

print, outfile

endfor
end
