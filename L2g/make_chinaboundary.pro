pro make_chinaboundary

;stateFile = Filepath(Subdirectory = ['resource', 'maps', 'shape'], $
;                     'canadaprovince.shp')

stateFile = '/home/liufei/IDL/tools/chinaboundary/bou2_4p.shp'
print,stateFile

shapefile = Obj_New('IDLffShape', stateFile)
IF Obj_Valid(shapefile) EQ 0 THEN $
  Message, 'Unable to create shape file object. Returning...'

shapefile -> GetProperty, ATTRIBUTE_NAMES=theNames

entities = Ptr_New(/Allocate_Heap)
*entities = shapefile -> GetEntity(/All)

FOR j = 0, N_Elements(*entities)-1 DO BEGIN
    thisEntity = (*entities)[j]
    entity = (*entities)[j]
        cuts = [*entity.parts, entity.n_vertices]
        FOR i = 0, entity.n_parts - 1 DO BEGIN
            PlotS, (*entity.vertices)[0, cuts[i]:cuts[i+1] - 1], $
              (*entity.vertices)[1, cuts[i]:cuts[i+1] - 1], $
              COLOR = !MYCT.BLACK, LINESTYLE = 0, THICK = 0.5
        ENDFOR
ENDFOR
END

