# Copyright (c) 2014 by Yauheni Kaliuta
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_GMAKE_MK
_MKC_GMAKE_MK := 1

CLEAN_TARGETS := clean cleandir distclean
EMPTY   :=
SPACE   := $(EMPTY) $(EMPTY)
COMMA	:= ,

.CURDIR = ${CURDIR}
.TARGET = $@
.ALLSRC = $^
.IMPSRC = $<
.PARSEDIR = $(realpath ${CURDIR}/$(dir $(lastword ${MAKEFILE_LIST})))

MAKEFLAGS += --no-print-directory

ifeq ($(origin COMPILE.cc),default)
undefine COMPILE.cc
endif
ifeq ($(origin COMPILE.c),default)
undefine COMPILE.c
endif

define tolower
$(shell echo $(1) | tr [:upper:] [:lower:])
endef

define toupper
$(shell echo $(1) | tr [:lower:] [:upper:])
endef

define seq
$(if $(subst $(1),,$(2))$(subst $(2),,$(1)),,T)
endef

define not
$(if $(1),,T)
endef

define is_defined
$(if $(filter undefined,$(origin $(1))),,T)
endef

# $(1) expression
# $(2) string to operate on
define sed
$(shell echo '$(2)' | sed -e '$(1)')
endef

# $(1) pattern
# $(2) list
# almost stub implementation
define filter-glob
$(foreach I,$(2),$(shell echo ${I} | grep '^$(subst *,.*,$(subst ?,.,$(subst .,[.],$(1))))$$'))
endef

bs := \\
define shell-quote
"$(subst ',${bs}',$(subst ",${bs}",$(1)))"
endef

# $(1) list of extentions to replace
# $(2) to which extention replace them
# $(3) filename list
define replace_extentions
$(eval _tmpvar := ${3})\
$(foreach ext,${1},$(eval \
_tmpvar := $(patsubst %.${ext},%.${2},${_tmpvar}))) \
${_tmpvar}
endef

# $(1) func
# $(2) list of pairs
define process_pairs
$(if $(2),$(call $(1),$(word 1,$(2)),$(word 2,$(2))) \
		$(call process_pairs,$(1),$(wordlist 3,$(words $(2)),$(2))))
endef

define check_dir
$(shell if test -d $(1); then echo T; fi)
endef

# transforms, for ex.: -o ${SCRIPTSOWN_${.ALLSRC:T}:U${SCRIPTSOWN}:Q}
# -o $(call gen_install_switch,SCRIPTSOWN)
gen_install_switch = $(firstword ${${1}_$(notdir $^)} ${${1}})

# workaround of possibility to overrride default targets
# since there is no commands(target)
#.SECONDEXPANSION:
#%: $$(__default_$$@_deps)
#	$(if $(call is_defined,__default_$@),\
#	     $(__default_$@), \
#	     $(error No default rule for $@ defined))

ifdef MAKEOBJDIRPREFIX
ifneq ($(call check_dir,${MAKEOBJDIRPREFIX}${.CURDIR}),)
.OBJDIR = ${MAKEOBJDIRPREFIX}${.CURDIR}
endif
endif

ifdef MAKEOBJDIR
ifneq ($(call check_dir,${MAKEOBJDIR}),)
.OBJDIR ?= ${MAKEOBJDIR}
endif
endif

ifneq ($(call check_dir,${.CURDIR}/obj.${MACHINE}),)
.OBJDIR ?= ${.CURDIR}/obj.${MACHINE}
endif

ifneq ($(call check_dir,${.CURDIR}/obj),)
.OBJDIR ?= ${.CURDIR}/obj
endif

ifneq ($(call check_dir,/usr/obj/${.CURDIR}),)
.OBJDIR ?= /usr/obj/${.CURDIR}
endif

.OBJDIR ?= ${CURDIR}

endif
