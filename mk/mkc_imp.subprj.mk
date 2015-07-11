# Copyright (c) 2010-2013 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_SUBPRJ_MK
_MKC_IMP_SUBPRJ_MK := 1

EXPORT_VARNAMES +=	STATICLIBS COMPATLIB

$(eval \
__REALSUBPRJ += $(filter-out ${NOSUBDIR},$(subst :, ,${SUBPRJ})))

$(foreach dir,${NOSUBDIR},$(eval \
NODEPS +=	*-${dir}:* *:*-${dir}   *-*/${dir}:* *:*-*/${dir} \
))

$(foreach dir,${INTERNALLIBS},$(eval \
NODEPS +=	install-${dir}:*     install-*/${dir}:* \
		uninstall-${dir}:*   uninstall-*/${dir}:* \
		installdirs-${dir}:* installdirs-*/${dir}:* \
))

ifndef SUBDIR
__REALSUBPRJ := $(sort ${__REALSUBPRJ})
endif

__dash_subdirs := $(strip $(call filter-glob,*-*,${__REALSUBPRJ}))
ifneq (${__dash_subdirs},)
$(error Dash symbol is not allowed inside subdir (${__dash_subdirs}))
endif

SUBPRJ_DFLT ?=	${__REALSUBPRJ}

# for each ${targ}
# for each ${dir}
define __real_subprj
$(eval _ALLTARGDEPS3 +=	${targ}-${dir})
.PHONY: nodeps-${targ}-${dir}   subdir-${targ}-${dir}   ${targ}-${dir}
nodeps-${targ}-${dir}: nodeps-${targ}-%:
	+${__recurse}
${targ}-${dir}: ${targ}-%:
	+${__recurse}
subdir-${targ}-${dir}: subdir-${targ}-%:
	+${__recurse}

ifeq ($(call tolower,${SHORTPRJNAME}),yes)
__not_dir := $(notdir ${dir})
ifneq (${dir},${__not_dir})
$(eval _ALLTARGDEPS3 +=	${targ}-${__not_dir})
.PHONY: nodeps-${targ}-${__not_dir}
.PHONY: subdir-${targ}-${__not_dir}
.PHONY: .${targ}-${__not_dir}
nodeps-${targ}-${__not_dir}: nodeps-${targ}-${dir}
       ${targ}-${__not_dir}:        ${targ}-${dir}
subdir-${targ}-${__not_dir}: subdir-${targ}-${dir}
$(eval _ALLTARGDEPS3 +=	${targ}-${dir}:${targ}-${__not_dir})
endif
endif
endef

# __prev_dir :=
# for each ${targ}
# for each ${dir}
define __subprj_dflt
ifeq (${dir},.WAIT)
__dep := ${targ}-${__prev_dir}
else

__prev_dir := ${dir}
ifneq (${__dep},)
${targ}-${dir}: ${__dep}
endif

$(eval _SUBDIR_${targ} += ${targ}-${dir}:${targ})

endif # .WAIT
endef

define __target

$(foreach dir,$(filter-out .WAIT,${__REALSUBPRJ}),\
	$(eval $(value __real_subprj)))

#TODO
#.if !commands(${targ})

__prev_dir :=
$(foreach dir,${SUBPRJ_DFLT},$(eval $(value __subprj_dflt)))

$(eval _SUBDIR_${targ} := $(filter-out ${NODEPS},${_SUBDIR_${targ}}))
$(eval _ALLTARGDEPS2 += ${_SUBDIR_${targ}})
${targ}: $(patsubst %:${targ},%,${_SUBDIR_${targ}})

#.endif #!command(${targ})

$(foreach DEP:PRJ,$(call filter-glob,*:*,${SUBPRJ}),$(eval \
_ALLTARGDEPS += ${targ}-$(firstword $(subst :, ,${DEP:PRJ})):${targ}-$(lastword $(subst :, ,${DEP:PRJ})) \
))
endef

$(foreach targ,${TARGETS},$(eval $(value __target)))

#################################################

# for each ${dir}
define __real_subprj2
ifeq ($(call tolower,${SHORTPRJNAME}),yes)
__not_dir := $(notdir ${dir})
ifneq (${dir},${__not_dir})
$(eval SRCDIR_${__not_dir} = ${.CURDIR}/${dir})
$(eval EXPORT_VARNAMES +=	SRCDIR_${__not_dir})
$(eval _ALLTARGDEPS    +=	all-${dir}:${__not_dir})
$(eval _ALLTARGDEPS3   +=	${__not_dir})
endif
endif # .if ${SHORTPRJNAME:tl} == "yes" ...

j := $(subst /,_,${dir})
ifeq ($(subst .,,${j}),${j})
$(eval SRCDIR_${j} = ${.CURDIR}/${dir})
$(eval EXPORT_VARNAMES += SRCDIR_${j})
endif # .if dir contains .
$(eval _ALLTARGDEPS += all-${dir}:${dir})
endef

$(foreach dir,${__REALSUBPRJ},$(eval $(value __real_subprj2)))

##################################################

_SUBDIR_${targ} := $(filter-out ${NODEPS},_SUBDIR_${targ})

_ALLTARGDEPS := $(filter-out ${NODEPS},${_ALLTARGDEPS})

# for each ${prj:dep}
define __prj_dep
prjtarg := $(firstword $(subst :, ,${prj:dep}))
deptarg := $(lastword $(subst :, ,${prj:dep}))
.PHONY: ${prjtarg} ${deptarg}
${prjtarg}: ${deptarg}
endef

$(foreach prj:dep,${_ALLTARGDEPS},$(eval $(value __prj_dep)))

define __echo
	@echo ${1}

endef

.PHONY: print_deps
print_deps:
	$(foreach i,${_ALLTARGDEPS} ${_ALLTARGDEPS2} ${_ALLTARGDEPS3} \
		    ${TARGETS},\
		$(call __echo,$(subst :, ,${i})))

define __clear_target
endef

define __recurse
	@targ=$(patsubst nodeps-%,%,$(call sed,s/-.*//,${.TARGET}))	\
	dir=$(patsubst nodeps-%,%,$(call sed,s/^[^-]*-//,${.TARGET}));	\
	if ! test -f ${.CURDIR}/$$dir/Makefile; then exit 0; fi;	\
	test "$${targ}_$(call tolower,${MKINSTALL})" = 'install_no' && exit 0; \
	test "$${targ}_$(call tolower,${MKINSTALL})" = 'installdirs_no' && exit 0; \
	${export_cmd}							\
	set -e;								\
	${VERBOSE_ECHO} ================================================== 1>&2;\
	case "$$dir" in /*)						\
		${VERBOSE_ECHO} "$$targ ===> $$dir" 1>&2;		\
		cd "$$dir";						\
		env "_THISDIR_=$$dir/" ${MAKE} $$targ;		\
		;;							\
	*)								\
		${VERBOSE_ECHO} "$$targ ===> ${_THISDIR_}$$dir" 1>&2;	\
		cd "${.CURDIR}/$$dir";					\
		env "_THISDIR_=${_THISDIR_}$$dir/" ${MAKE} $$targ; \
		;;							\
	esac
endef

###########
SUBPRJSRCTOP =	${.CURDIR}
export SUBPRJSRCTOP
###########

include mkc_imp.objdir.mk

endif # _MKC_IMP_SUBPRJ_MK
