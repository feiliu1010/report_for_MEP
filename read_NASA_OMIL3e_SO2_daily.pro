pro read_NASA_OMIL3e_SO2_daily

For year=2013,2013 do begin
Yr=String( Year, format = '(i4.4)' )
dir = '/z6/satellite/OMI/so2/NASA_L3e/v_2012_08_29/'+Yr+'/'

;spawn,'ls '+dir+'OMI-Aura_L3-OMSO2e_2012m0531* ',list_omi
spawn,'ls '+dir+'OMI-Aura_L3-OMSO2e_'+Yr+'m* ',list_omi

InType   = CTM_Type( 'generic', Res=[ 0.25, 0.25 ] )
InGrid   = CTM_Grid( InType, /No_Vertical )

for k=0, n_elements(list_omi)-1 do begin

infile = list_omi[k]

len  = strlen(infile)
Yr4  = strmid(infile,len-35,4)
Mon2 = strmid(infile,len-30,2)
Day2 = strmid(infile,len-28,2)

outfile='/home/liufei/Data/Satellite/SO2/NASA_L3e/OMI-Aura_L3-OMSO2e_'+ Yr4 + Mon2 + Day2 +'_v003.bpch'

Year = Fix(Yr4) 
Month = Fix(Mon2)
Day = Fix(Day2)
print,year,month,day

Nymd = Year * 10000L + Month * 100L + Day
tau0 = nymd2tau(Nymd)
print,Nymd

;GET DATA
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN( Infile)
   if ( fId lt 0 ) then Message, 'Error opening file!'

   dataId_1 = H5D_OPEN( fId, '/HDFEOS/GRIDS/OMI Total Column Amount SO2/Data Fields/ColumnAmountSO2_PBL')
   ColumnAmountSO2_PBL = H5D_READ(dataId_1)

H5D_CLOSE, dataId_1
H5F_CLOSE, fId

  ; Make a DATAINFO structure
   success = CTM_Make_DataInfo( ColumnAmountSO2_PBL,    $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=26,              $
                                Tau0= tau0,             $
                                Unit='DU',              $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outFile

endfor
endfor
end
