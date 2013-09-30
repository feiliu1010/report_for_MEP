FUNCTION percntle, array, p
nn = N_ELEMENTS(array)
ip = LONG(FLOAT(p) * nn/100.)
ii = SORT(array)
RETURN, array(ii(ip))
END
