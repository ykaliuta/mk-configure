OPT_FLAG ?=	-Os

MKC_CHECK_CXX_OPTS =	${OPT_FLAG}
MKC_CHECK_CC_OPTS =	${OPT_FLAG}

include mkc.configure.mk

ifeq (${HAVE_CXX_OPT.${OPT_FLAG}},1)
CXXFLAGS +=	${OPT_FLAG}
endif
