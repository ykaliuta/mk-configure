# Copyright (c) 2010 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP.PREINIT.MK
 _MKC_IMP.PREINIT.MK:=1

# $(1) dir to check 
define __check_dir
$(and $(filter-out undefined,$(origin $(1))),\
      $(if $(call seq,$(_top_mk),$(patsubst %,mkc.%.mk,$(call tolower,$(1)))),,\
           $(error $(1) is not allowed for $(_top_mk))))
endef

ifdef _top_mk
$(foreach dir,SUBDIR SUBPRJ PROG LIB,$(call __check_dir,$(dir)))
endif

####################

ifeq ($(filter ${CLEAN_TARGETS} obj,${MAKECMDGOALS}),)
MKCHECKS ?=	yes
else
MKCHECKS ?=	no
endif # clean/cleandir/distclean

endif # _MKC_IMP.PREINIT.MK
