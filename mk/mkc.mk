# Copyright (c) 2013 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_MK
_MKC_MK := 1

init_make_level ?= 0

_do_top_level :=

ifdef SRCTOP
ifneq (${SRCTOP},${CURDIR})
ifeq (${MAKELEVEL},${init_make_level})
_do_top_level := T
endif
endif
endif

ifneq ($(_do_top_level),)
MKC_CACHEDIR ?=	${SRCTOP}
export MKC_CACHEDIR
.DEFAULT_GOAL := all
.DEFAULT:
	@set -e; cd ${SRCTOP}; ${MAKE} $@-$(patsubst ${SRCTOP}/%,%,${CURDIR})
else
include mkc_imp.mk
endif

endif # _MKC_MK
