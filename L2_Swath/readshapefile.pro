Pro readshapefile
  shapefile='C:\ESRI\ESRIDATA\WORLD\country.shp' ;����shape�ļ�λ��
  oshp=OBJ_NEW('IDLffShape',shapefile)
  oshp->getproperty,n_entities=n_ent,Attribute_info=attr_info,n_attributes=n_attr,Entity_type=ent_type
  ;������ֵ
  for i=0,n_ent-1 do begin
    ent=oshp->getEntity(i)
    ;���ʵ�巶Χ
    print,'��Сx:',ent.bounds[0]
    print,'��Сy:',ent.bounds[1]
    print,'���x:',ent.bounds[4]
    print,'���y:',ent.bounds[5]
    ;�������ֵ
    vert=*(ent.vertices)
    print,'�������Ϊ:',ent.n_vertices
    print,vert
  endfor
  ;�����ṹ
  For i=0,n_attr-1 Do Begin ;ѭ��
    PRINT, '�ֶ����: ',i
    PRINT, '�ֶ���: ', attr_info[i].name
    PRINT, '�ֶ����ʹ���: ', attr_info[i].type
    PRINT, '�ֶο��: ', attr_info[i].width
    PRINT, '����: ', attr_info[i].precision
  Endfor 
  
  ;������Ա��е�ֵ   
  For i=0,n_ent-1 Do Begin ;ѭ����n_ent����¼����һ����
    attr=oshp->GetAttributes(i) ;��ȡ��i����¼
    For index=0, n_attr-1 Do Begin
      PRINT,attr_info[index].name,' = ',attr.(index)
    Endfor
  Endfor
  OBJ_DESTROY,oshp ;����һ��shape����
  print,'---end----'
End