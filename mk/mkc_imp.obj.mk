# Copyright (c) 2013 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_OBJ_MK
_MKC_IMP_OBJ_MK := 1

obj: # ensure existence

ifdef MAKEOBJDIRPREFIX
__objdir :=	${MAKEOBJDIRPREFIX}${.CURDIR}
else ifdef MAKEOBJDIR
__objdir :=	${MAKEOBJDIR}
endif # defined(MAKEOBJDIRPREFIX)

ifdef __objdir

#TODO what Aleksey whanted here?

ifeq ($(call tolower,${MKOBJDIRS}),yes)
ifndef SUBPRJ

obj:
	@${MKDIR} -p ${__objdir}
endif # !defined(SUBPRJ)
else ifeq ($(call tolower,${MKOBJDIRS}),auto)

obj: | ${__objdir}

${__objdir}:
	@${MKDIR} -p $@
endif # MKOBJDIRS

endif # defined(__objdir)...
endif # _MKC_IMP_OBJ_MK
