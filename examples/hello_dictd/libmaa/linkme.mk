PATH.maa :=	${.PARSEDIR}

CPPFLAGS  +=	-I${PATH.maa}
DPLIBDIRS +=	${PATH.maa}
DPLIBS    +=	-lmaa
