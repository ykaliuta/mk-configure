# Copyright (c) 2012 by Aleksey Cheusov
#
# See LICENSE file in the distribution.

ifndef _MKC_IMP_OBJDIR_MK
_MKC_IMP_OBJDIR_MK := 1

ifneq ($(call check_dir,${.CURDIR}/obj.${MACHINE}),)
_OBJ_MACHINE_DIR := ${.CURDIR}/obj.${MACHINE}
else ifneq ($(call check_dir,${.CURDIR}/obj),)
_OBJ_DIR := ${.CURDIR}/obj
endif

# ${i} is subproject name
define __set_subprj_objdir
j := $(subst /,_,${i})

# skip names with ., like ../sub/project
ifeq ($(subst .,,${j}),${j})
$(eval EXPORT_VARNAMES += OBJDIR_${j})
ifeq ($(call tolower,${MKRELOBJDIR}),yes)
OBJDIR_${j} := ${.OBJDIR}/${i}
else ifdef MAKEOBJDIRPREFIX
OBJDIR_${j} := ${MAKEOBJDIRPREFIX}${.CURDIR}
else ifdef MAKEOBJDIR
OBJDIR_${j} := ${MAKEOBJDIR}
else ifdef _OBJ_MACHINE_DIR
OBJDIR_${j} := ${_OBJ_MACHINE_DIR}
else ifdef _OBJ_DIR
OBJDIR_${j} := ${_OBJ_DIR}
else
OBJDIR_${j} := ${.CURDIR}/${i}
endif # MAKEOBJDIRPREFIX...

ifeq  ($(call tolower,${SHORTPRJNAME}),yes)
ifneq (${i},${j})
$(eval OBJDIR_$(notdir ${i}) := ${OBJDIR_${j}})
$(eval EXPORT_VARNAMES += OBJDIR_$(notdir ${i}))
endif
endif
endif # . check
endef

$(foreach i,${__REALSUBPRJ},$(eval $(value __set_subprj_objdir)))

undefine _OBJ_MACHINE_DIR
undefine _OBJ_DIR

endif # _MKC_IMP_OBJDIR_MK
