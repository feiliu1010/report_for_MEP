pro plot_omi_so2_compare

year=2012
year1=year+1

Yr4 = string(year, format='(i4.4)')
Yr41= string(year1, format='(i4.4)')

;Season = 'JantoMar'
Season = 'JantoJun'
;Season = 'JantoSep'
;Season = 'annual'
;Season ='JantoMay'

limit=[15,72,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.1
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 1

;portrait
xmax = 15
ymax = 6

xsize= 14
ysize= 4.5

XOffset = ( XMax - XSize ) / 4.0
YOffset = ( YMax - YSize ) 

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='./compare_NASA_L3e_OMI_SO2_column_'+Yr4+'_'+Yr41+'_'+Season+'_05x05.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename1 = '/home/liufei/Data/Satellite/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr4+'_'+Season+'_v003.05x05.bpch'
filename2 = '/home/liufei/Data/Satellite/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+Yr41+'_'+Season+'_v003.05x05.bpch'

ctm_get_data,datainfo1,'IJ-AVG-$',filename = filename1,tracer=26
data18=*(datainfo1[0].data)

ctm_get_data,datainfo2,'IJ-AVG-$',filename = filename2,tracer=26
data28=*(datainfo2[0].data)

;InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

mi = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1L do begin
for J = 0,InGrid.JMX-1L do begin

    if (data28[I,J] ge -10.0 and data18[I,J] ge -10.0) then begin 
        mi[I,J] = data28[I,J] - data18[I,J]
    endif

endfor
endfor

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

Margin=[ 0.03, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0
maxdata = 1.6

; NOx emissions
data818 = data18[I1:I2, J1:J2] 
data828 = data28[I1:I2, J1:J2]  
mi818 = mi[I1:I2, J1:J2]

Myct, /WhGrYlRd, ncolors=40

tvmap,data818,                                          $   
limit=limit,					        $     
/nocbar,         				        $     
mindata = mindata, $
maxdata = maxdata, $
;cbmin = mindata, cbmax = maxdata, $
;divisions = 9, $
;cbformat = '(i2)',$
;cbposition=[0.3 , 0.02, 1.7, 0.05 ],                 $
;/countries,/continents,/Coasts,    		        $
;/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
;title='OMI',			        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_asiaboundary
make_chinaboundary



tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata, $
maxdata = maxdata, $
;cbmin = mindata, cbmax = maxdata, $
;divisions = 9, $
;/countries,/Coasts,/continents,                         $
;/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
;title='GC_S0',    $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

   Colorbar,                                                     $
      Position=[ 0.15, 0.1, 0.6, 0.135],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],                       $
      Divisions=9, $
      ;c_colors=c_colors,C_levels=C_levels,                      $
      Min=mindata, Max=maxdata, Unit='',format = '(f3.1)',charsize=1.2

myct,/BuWhRd,ncolors=24

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_asiaboundary
make_chinaboundary


tvmap,mi818,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = -1.0, $
maxdata = 1.0, $
cbmin = -1.0, cbmax = 1.0, $
divisions = 11, $
cbformat='(f4.1)',$
;/countries,/Coasts,/continents,                         $
;/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
;title='OMI minus GC_S0',    $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

 multipanel, /noerase
    Map_limit = limit
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position3,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_asiaboundary
make_chinaboundary



   Colorbar,                                                     $
      Position=[ 0.71, 0.1, 0.95, 0.135],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],                       $
      Divisions=9, $
      ;c_colors=c_colors,C_levels=C_levels,                      $
      Min=-1.0, Max=1.0, Unit='',format = '(f4.1)',charsize=1.2
 ;Min=-2, Max=2, Unit='',format = '(f4.1)',charsize=1.2

   TopTitle = 'DU'
      XYOutS, 0.35, 0.0, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.3,                                                $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = 'DU'
      XYOutS, 0.83, 0.0, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.3,                                                $ ; Set text size to twice normal size
      Align=0.5 

   TopTitle = Yr4

      XYOutS, 0.21, 0.95,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.5,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

   TopTitle = Yr41

      XYOutS, 0.52, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = Yr41+'minus'+Yr4

      XYOutS, 0.83, 0.95,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.5,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

close_device
end
