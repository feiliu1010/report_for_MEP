pro plot_result_epgc_CO_bymonth_Asia

; ---S1 result, by sector-----
Species  = ['CO']
Year = [2008]
Source = ['Anthropogenic']
;Source = ['RE','IN','PO','TR']
Basedir = '/home/limeng/ep-gc/data/2/S2/'
;Basedir = '/home/limeng/ep-gc/data/2/S1/'
Intype = ctm_type('generic',res=[ 2d0/3d0,0.5d0],Halfpolar=0,Center180=0)
Ingrid = ctm_grid(Intype)

Xmid = Ingrid.xmid
Ymid = Ingrid.ymid
close,/all
Season = [1,4,7,10]
Indata = fltarr(Ingrid.imx, Ingrid.jmx,4) ; 4months ,1,4,7,10, total emission

;------------domain for GC-------------
; East Asia : 11S-55N, 70E-150E
; North America: 10N-70N, 140W-40W
; Europe : 30N-70N, 30W - 50E
; source: http://wiki.seas.harvard.edu/geos-chem/index.php/Setting_up_GEOS-Chem_nested_grid_simulations
; source : geos-chem user guide
for y = 0,n_elements(Year)-1 do begin
    Y4 = string(Year[y], format='(i4.4)')
    for sea  = 0,n_elements(Season)-1 do begin
        m = Season[sea]
        m2 = string(m, format='(i2.2)')
        Infile = Basedir + Y4+ m2 + '.nc'
        print, Infile
        fid = ncdf_open( Infile,/NOWRITE)
        
        for sp = 0,n_elements(Species)-1 do begin
            for s = 0,n_elements(Source)-1 do begin
                emvid = ncdf_varid(fid, Species[sp] + '_' + Source[s])
                ncdf_varget, fid, emvid, regiondata
                InData[*,*,sea] += regiondata[*,*] ; only used in one species
             endfor
        endfor
        ncdf_close, fid
     endfor
endfor 
        
; ---EA domain---
x1 = where( Xmid ge 70.0 and Xmid le 70.0+0.3335 )
x2 = where( Xmid ge 150.0 and Xmid le 150.0+0.3335)
y1 = where( Ymid ge -11.0 and Ymid le -11.0+0.3335)
y2 = where( Ymid ge 55.0 and Ymid le 55.0+0.3335)

limit1 = [ymid[y1], xmid[x1], ymid[y2], xmid[x2]]
Out1 = fltarr(x2-x1+1, y2-y1+1, 4)
Out1[*,*,*] = InData[x1:x2, y1:y2, 0:3] / 1000.0 ; Gg/grid
Temp = fltarr(x2-x1+1, y2-y1+1)

print, 'EA', total(Out1)

;  ---NA domain---
;x1 = where( Xmid ge -140.0 and Xmid le -140.0+0.3335 )
;x2 = where( Xmid ge -40.0 and Xmid le -40.0+0.3335)
;y1 = where( Ymid ge 10.0 and Ymid le 10.0+0.3335)
;y2 = where( Ymid ge 70.0 and Ymid le 70.0+0.3335)

;limit2 = [ymid[y1], xmid[x1], ymid[y2], xmid[x2]]
;Out2 = fltarr(x2-x1+1, y2-y1+1,4)
;Out2[*,*,*] = InData[x1:x2, y1:y2, 0:3] / 1000.0 ; change to Gg/grid
;print, 'NA', total(Out2)

;  ---EU domain---
;x1 = where( Xmid ge -30.0 and Xmid le -30.0+0.3335 )
;x2 = where( Xmid ge 50.0 and Xmid le 50.0+0.3335)
;y1 = where( Ymid ge 30.0 and Ymid le 30.0+0.3335)
;y2 = where( Ymid ge 70.0 and Ymid le 70.0+0.3335)

;limit3 = [ymid[y1], xmid[x1], ymid[y2], xmid[x2]]
;Out3 = fltarr(x2-x1+1, y2-y1+1, 4)
;Out3[*,*,*] = InData[x1:x2, y1:y2, 0:3] / 1000.0
;print, 'EU', total(oUT3)

;--------plot here, output .ps file----------------------

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

;portrait
xmax = 15
ymax = 15

xsize= 14
ysize= 14

XOffset = ( XMax - XSize ) / 4.0
YOffset = ( YMax - YSize ) / 2.0
; plot here !!
Margin = [0.01,0.01,0.01,0.01]

print, total(Out1[*,*,0]),total(Out1[*,*,1]),total(Out1[*,*,2]),total(Out1[*,*,3])
Outfile = '/home/limeng/r6/For_Preprocessor/Output/Test_EPGC/CO_AllSector_2008_result_bymonth_Asia.ps'

open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename=Outfile, $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

multipanel, omargin=[0.02,0.05,0.03,0.01],col = 2, row = 2
Myct, 33, /verbose

maxdata = 30
tvmap,Out1[*,*,0],     $
mindata = mindata,     $
maxdata = maxdata,           $
/countries,/continents,/Coasts,   $
/CHINA,            $
Ccolor = !MYCT.GRAY, $
limit = limit1,$
charsize=1.5,$
divisions=11,$
margin = margin,   $
/Sample,           $
/cbar,             $
cbposition=[0.5,0.02,1.5,0.06],$
position=position1,$
/Quiet,/Noprint,   $
/grid, dlat=10,dlon=20,gcolor=gcolor

tvmap,Out1[*,*,1],     $
mindata = mindata,     $
maxdata = maxdata,           $
/countries,/continents,/Coasts,   $
/CHINA,            $
Ccolor = !MYCT.GRAY, $
limit = limit1,$
charsize=1.5,$
divisions=11,$
margin = margin,   $
/Sample,           $
/nocbar,$
cbposition=[0.5,0.03,1.5,0.07],$
position=position2,$
/Quiet,/Noprint,   $
/grid, /NOGYLABELS

tvmap,Out1[*,*,2],     $
mindata = mindata,     $
maxdata = maxdata,           $
/countries,/continents,/Coasts,   $
/CHINA,            $
Ccolor = !MYCT.GRAY, $
limit = limit1,$
charsize=1.5,$
divisions=11,$
margin = margin,   $
/Sample,          $
/nocbar,$
cbposition=[0.5,0.02,1.5,0.06],$
position=position3,$
/Quiet,/Noprint,   $
/grid, dlat=10,dlon=20,gcolor=gcolor

;maxdata = 100
;mindata = -100
;Temp[*,*] = Out1[*,*,0]-Out1[*,*,2]
;print, min(Temp),max(Temp), total(Temp)
tvmap,Out1[*,*,3],     $
mindata = mindata,     $
maxdata = maxdata,           $
/countries,/continents,/Coasts,   $
/CHINA,            $
Ccolor = !MYCT.GRAY, $
limit = limit1,$
charsize=1.5,$
divisions=11,$
margin = margin,   $
/Sample,          $
/nocbar,$
cbposition=[0.0,0.02,1.0,0.06],$
position=position4,$
/Quiet,/Noprint,   $
/grid, /NOGYLABELS

Toptitle = 'EP-GC CO Total Emissions for 2008 by Season, resolution: 0.5x0.667'
Title1 = 'January'
Title2 = 'April'
Title3 = 'July'
Title4 = 'October'
Unit = 'Unit : Gg/grid'

     XYOutS, 0.5, 1.01, TopTitle,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.BLACK,                              $ ; Set text color to black
      CharSize=3.0,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center text

     XYOutS, 0.4, 0.65, Title1,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.WHITE,                              $ ; Set text color to black
      CharSize=2.5,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center text

     XYOutS, 0.87, 0.65, Title2,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.WHITE,                              $ ; Set text color to black
      CharSize=2.5,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center text

     XYOutS, 0.4, 0.17, Title3,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.WHITE,                              $ ; Set text color to black
      CharSize=2.5,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center 

     XYOutS, 0.87, 0.17, Title4,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.WHITE,                              $ ; Set text color to black
      CharSize=2.5,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center

     XYOutS, 0.80, 0.53, Unit,                      $
      /Normal,                                        $ ; Use normal coordinates
      Color=!MYCT.BLACK,                              $ ; Set text color to black
      CharSize=2.5,                                   $ ; Set text size to twice normal size
      Align=0.5                                       ; Center

close_device

end
