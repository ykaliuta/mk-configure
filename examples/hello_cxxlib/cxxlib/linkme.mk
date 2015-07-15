.PARSEDIR := $(realpath ${CURDIR}/$(dir $(lastword ${MAKEFILE_LIST})))
PATH.cxxlib :=	$(abspath ${.PARSEDIR})

DPINCDIRS +=	${PATH.cxxlib}/include
DPLIBDIRS +=	${PATH.cxxlib}
DPLDADD   +=	cxxlib
