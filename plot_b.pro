pro plot_b

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_OverLay

limit = [17.25,71,54,140]


outfile = '/home/liufei/r5/IDL/report_for_MEP/result/201201_201209/ratio.ps'

filter = 0

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.2
!p.font = 1.0

multipanel, omargin=[0.02,0.02,0.02,0.02],col = 1, row = 1

;portrait
xmax = 9
ymax = 9

xsize= 8
ysize= 7

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

InType = CTM_Type( 'generic',res=[0.5d0,0.5d0],halfpolar=0,center180=0)
InGrid = CTM_Grid( InType )
xmid = InGrid.xmid
ymid = InGrid.ymid

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename=outfile, $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename1 ='/home/liufei/r5/IDL/report_for_MEP/result/201201_201209/OMI-L3-NO2_SO2_ratio_2012_05x05.bpch'
ctm_get_data,datainfo1,filename = filename1,tracer=1,tau0=nymd2tau(20110101L)
data18=*(datainfo1[0].data)
print,'max',max(data18,min=min),'min',min,'mean',mean(data18)


limit_now = limit
print,limit_now

i1_index = where(xmid ge limit_now[1] and xmid le limit_now[3])
j1_index = where(ymid ge limit_now[0] and ymid le limit_now[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data18[I1:I2, J1:J2]

Margin=[ 0.02, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0
maxdata = 3

Myct,/whGrYlRd,ncolors=40

; region boundary for Neimeng

tvmap,data818,  $
limit=limit_now,   $     
mindata = mindata, $
maxdata = maxdata, $
/nocbar,           $     
cbmin = mindata, cbmax = maxdata, $
divisions = 11,    $
cbformat='(i2.1)', $
;/cbvertical, $
;/countries,/continents,/Coasts,   $
;/CHINA,	           $         
margin = margin,   $  
/Sample,           $         
position=position1,$
;title='(a) OMI-annual',      $
/Quiet,/Noprint,   $
/grid, skip=1,gcolor=gcolor

print,position1

    multipanel, /noerase
    Map_limit = limit_now
    ; Plot grid lines on the map
    Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
    LatRange = [ Map_Limit[0], Map_Limit[2] ]
    LonRange = [ Map_Limit[1], Map_Limit[3] ]
make_asiaboundary
make_chinaboundary


; -----------------------------------------------------
; region boundary plot begins here
; -----------------------------------------------------
;goto,next

; region boundary for Ningxia

;TrackX1 = [103,107.5,107.5,103,103]
;TrackY1 = [36,36,40.0,40.0,36]

;plots,TrackX1,TrackY1,linestyle=0,thick=3,color=!MYCT.WHITE

; region boundary for Sichuan

;TrackX2 = [102.3333,107.6667,107.6667,102.3333,102.3333]
;TrackY2 = [25,25,31.75,31.75,25]

;plots,TrackX2,TrackY2,linestyle=0,thick=3,color=!MYCT.WHITE

; region boundary for CEC

;TrackX3 = [110,123,123,110,110]
;TrackY3 = [30,30,40,40,30]

;plots,TrackX3,TrackY3,linestyle=0,thick=3,color=!MYCT.WHITE

; region boundary for NE

;TrackY4 = [39.5,39.5,41.5,41.5,46.5,46.5,42.5,42.5,39.5]
;TrackX4 = [121.3333,124.6667,124.6667,127.3333,127.3333,123.3333,123.3333,121.3333,121.3333]

;plots,TrackX4,TrackY4,linestyle=0,thick=3,color=!MYCT.GREEN

; region boundary for BTH

;TrackX5 = [115.3333,118.6667,118.6667,115.3333,115.3333]
;TrackY5 = [39,39,41,41,39]

;plots,TrackX5,TrackY5,linestyle=0,thick=3,color=!MYCT.GREEN

; region boundary for YRD

;TrackX6 = [118.6667,122,122,118.6667,118.6667]
;TrackY6 = [29.75,29.75,32.75,32.75,29.75]

;plots,TrackX6,TrackY6,linestyle=0,thick=3,color=!MYCT.GREEN

; region boundary for PRD

;TrackX7 = [112,114.6667,114.6667,112,112]
;TrackY7 = [21.5,21.5,24,24,21.5]

;plots,TrackX7,TrackY7,linestyle=0,thick=3,color=!MYCT.WHITE

; region boundary for Shaanxi Background

;TrackX8 = [107.1,109.6,109.6,107.1,107.1]
;TrackY8 = [35.25,35.25,38.5,38.5,35.25]

;plots,TrackX8,TrackY8,linestyle=0,thick=3,color=!MYCT.GREEN

; region boundary for Fujian

;TrackX9 = [117.25,119.75,119.75,118.5,118.5,117.25,117.25]
;TrackY9 = [24,24,26.75,26.75,25.5,25.5,24]

;plots,TrackX9,TrackY9,linestyle=0,thick=3,color=!MYCT.WHITE

;TrackX10 = [111.5,113.75,113.75,111.5,111.5]
;TrackY10 = [27.25,27.25,30,30,27.25]

;plots,TrackX10,TrackY10,linestyle=0,thick=3,color=!MYCT.WHITE


;next:
; -----------------------------------------------------
; region boundary plot ends here
; -----------------------------------------------------

   Colorbar, $
      position=[0.15, 0.1, 0.85, 0.12 ], $
      Divisions=11,$
      Color=!MYCT.BLACK,                   $ ; Set text color to black
      ;/vertical,$;/triangle, $
      Min=mindata, Max=maxdata, format='(i3.1)', Unit='',charsize=0.9      

  ; TopTitle = 'Gg/Yr'
    TopTitle =''                
      XYOutS, 0.9, 0.0815, TopTitle,      $
      /Normal,                             $ ; Use normal coordinates
      Color=!MYCT.BLACK,                   $ ; Set text color to black
      CharSize=1.0,                        $ ; Set text size to twice normal size
      Align=0.5                              ; Center text

   TopTitle = ''

      XYOutS, 0.5, 1.25,TopTitle,          $
      /Normal,                 		   $ ; Use normal coordinates
      Color=!MYCT.BLACK, 		   $ ; Set text color to black
      CharSize=1.4,  			   $ ; Set text size to twice normal size
      Align=0.5     			     ; Center text

close_device

end
