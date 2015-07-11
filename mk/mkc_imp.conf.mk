# Copyright (c) 2009-2014, Aleksey Cheusov <vle@gmx.net>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

######################################################################
# See  mk-configure(7) for documentation
#

# user defined variables
# set it to `1' to show "...(cached)..." lines
MKC_SHOW_CACHED     ?= 0
# set it to `1' to delete temporary files
MKC_DELETE_TMPFILES ?= 0
# directory for cache and intermediate files
MKC_CACHEDIR        ?= ${.OBJDIR}
# list of headers always #included
MKC_COMMON_HEADERS  ?=
# 1 or yes for disabling cache
MKC_NOCACHE         ?=
# directory with custom tests.c
MKC_CUSTOM_DIR      ?=${CURDIR}
# directory with missing strlcat.c etc.
MKC_SOURCE_DIR      ?=${CURDIR}
#.if !empty(COMPATLIB) && ${COMPATLIB:U} != ${.CURDIR:T}
ifdef COMPATLIB
ifneq (${COMPATLIB},$(notdir ${CURDIR}))
MKC_NOSRCSAUTO      ?=	1
endif
endif
MKC_NOSRCSAUTO      ?=	0

#
MKC_SOURCE_FUNCLIBS   ?=
_MKC_SOURCE_FUNCS      =	$(call sed,s/:.*//,${MKC_SOURCE_FUNCLIBS})

# .endif for the next .if is in the end of file
ifeq ($(call tolower,${MKCHECKS}),yes)

HAVE_FUNCLIB.main ?=	1

CPPFLAGS +=		${MKC_COMMON_DEFINES.${TARGET_OPSYS}}
CPPFLAGS +=		${MKC_COMMON_DEFINES}

#
_MKC_CPPFLAGS :=	${CPPFLAGS}
_MKC_CFLAGS   :=	${CFLAGS}
_MKC_CXXFLAGS :=	${CXXFLAGS}
_MKC_FFLAGS   :=	${FFLAGS}
_MKC_LDFLAGS  :=	${LDFLAGS}
_MKC_LDADD    :=	${LDADD}

mkc.environ=PATH='${PATH}' CC='${CC}' CXX='${CXX}' FC='${FC}' CPPFLAGS='${_MKC_CPPFLAGS}' CFLAGS='${_MKC_CFLAGS}' CXXFLAGS='${_MKC_CXXFLAGS}' FFLAGS='${_MKC_FFLAGS}' LDFLAGS='${_MKC_LDFLAGS}' LDADD='${_MKC_LDADD}' LEX='${LEX}' YACC='${YACC}' MKC_CACHEDIR='${MKC_CACHEDIR}' MKC_COMMON_HEADERS='${MKC_COMMON_HEADERS}' MKC_DELETE_TMPFILES='${MKC_DELETE_TMPFILES}' MKC_SHOW_CACHED='${MKC_SHOW_CACHED}' MKC_NOCACHE='${MKC_NOCACHE}' MKC_VERBOSE=1

######################################################
# checking for builtin checks
define check_builtins_loop
$(eval MKC_CUSTOM_FN.${i} ?=	${BUILTINSDIR}/$(subst endianess,endianness,${i}))
$(eval MKC_CHECK_CUSTOM   +=	${i})
$(eval MKC_REQUIRE_CUSTOM +=	$(filter ${i},${MKC_REQUIRE_BUILTINS}))
endef

$(foreach i,${MKC_CHECK_BUILTINS} ${MKC_REQUIRE_BUILTINS},\
	$(eval $(value check_builtins_loop)))

######################################################
# checking for headers

define check_headers_loop
suffix := $(subst /,_,$(subst .,_,${h}))
SUFFIX := $(call toupper,${suffix})
ifndef HAVE_HEADER.${suffix}
HAVE_HEADER.${suffix} := $(shell env ${mkc.environ} mkc_check_header ${h})
endif

ifneq (${HAVE_HEADER.${suffix}},0)
ifeq ($(filter ${h},${MKC_REQUIRE_HEADERS}),)
$(eval MKC_CFLAGS  +=	-DHAVE_HEADER_${SUFFIX}=${HAVE_HEADER.${suffix}})
endif
#!empty(MKC_REQUIRE_HEADERS:U:M${h})
else ifneq ($(filter ${h},${MKC_REQUIRE_HEADERS}),)
_fake   !=   env ${mkc.environ} mkc_check_header -d ${h} && echo
$(eval MKC_ERR_MSG +=	"ERROR: cannot find header ${h}")
endif
endef

$(foreach h,${MKC_CHECK_HEADERS} ${MKC_REQUIRE_HEADERS},\
	$(eval $(value check_headers_loop)))

undefine MKC_CHECK_HEADERS
undefine MKC_REQUIRE_HEADERS

######################################################
# checking for functions in libraries

define check_funclibs_loop

$(eval HAVE_FUNCLIB.$(subst :,.,${f}) ?= $(shell env ${mkc.environ} mkc_check_funclib $(subst :, ,${f})))
$(eval HAVE_FUNCLIB.$(call sed,s/:.*//,${f}) ?= $(shell env ${mkc.environ} mkc_check_funclib $(call sed,s/:.*//,${f})))

ifneq (${HAVE_FUNCLIB.$(call sed,s/:.*//,${f})},${HAVE_FUNCLIB.$(subst :,.,${f})})
ifeq ($(filter $(subst :,.,${f}),$(subst :,.,${MKC_NOAUTO_FUNCLIBS})),)
ifeq (${MKC_NOAUTO_FUNCLIBS},)
ifneq (${HAVE_FUNCLIB.$(subst :,.,${f})},0)
ifeq (${HAVE_FUNCLIB.$(call sed,s/:.*//,${f})}),0)

MKC_LDADD +=	-l$(call sed,s/^.*://,{f})

endif
endif
endif
endif
endif

ifeq (${HAVE_FUNCLIB.$(subst :,.,${f})},0)
ifeq (${HAVE_FUNCLIB.$(call sed,s/:.*//,${f})},0)
ifneq ($(filter $(call sed,s/:.*//,${f}),${_MKC_SOURCE_FUNCS}),)

_varsuffix := $(call sed,s/:.*//,${f}).c
_varname := MKC_SOURCE_DIR.${_varsuffix}

$(eval MKC_SRCS += $(or ${${_varname}},${MKC_SOURCE_DIR}/${_varsuffix}))

endif
endif
endif

endef

$(foreach f,${MKC_CHECK_FUNCLIBS} ${MKC_SOURCE_FUNCLIBS} ${MKC_REQUIRE_FUNCLIBS}, $(eval $(value check_funclibs_loop)))

define check_require_funclibs
ifeq ($(filter 1,${HAVE_FUNCLIB.$(subst :,./${f})}),)
ifeq ($(filter 1,${HAVE_FUNCLIB.$(call sed,s/:.*//,${f})}),)

_fake   !=   env ${mkc.environ} mkc_check_funclib -d $(call sed,s/:.*//,${f}) && echo
_fake   !=   env ${mkc.environ} mkc_check_funclib -d $(subst :, ,${f} && echo
MKC_ERR_MSG +=	"ERROR: cannot find function ${f}"
endif
endif
endef

$(foreach f,${MKC_REQUIRE_FUNCLIBS},$(eval $(value check_require_funclibs)))

undefine MKC_CHECK_FUNCLIBS
undefine MKC_REQUIRE_FUNCLIBS

######################################################
# checking for sizeof(xxx)

define check_sizeof
SIZEOF_SUFFIX := $(subst :,.,$(subst /,_,$(subst *,P,$(subst -,_,$(subst .,_,${t})))))

__varname := SIZEOF.${SIZEOF_SUFFIX}
ifndef ${__varname}
${__varname} := $(shell env ${mkc.environ} mkc_check_sizeof $(subst :, ,${t}))
endif

ifneq (${${__varname}},failed)
DSIZEOF_SUFFIX := $(call toupper,$(subst .,_,$(subst :,_,$(subst *,P,$(subst $(SPACE),_,$(subst -,_,${t}))))))
$(eval MKC_CFLAGS += -DSIZEOF_${DSIZEOF_SUFFIX}=${${__varname}})
endif
endef

$(foreach t,${MKC_CHECK_SIZEOF},$(eval $(value check_sizeof)))

undefine MKC_CHECK_SIZEOF

######################################################
# checking for declared #define, types, variables, struct members
#  			and declared functions
# make_suffix function below, defined separately for different contexts

define check_have_one
ifeq (${ONE},VAR)
__check_decl_arg := variable
else
__check_decl_arg = ${one}${n}
endif

SUFFIX := $(call make_suffix,${i})
ifndef HAVE_${ONE}${n}.${SUFFIX}
HAVE_${ONE}${n}.${SUFFIX} := $(shell \
	env ${mkc.environ} mkc_check_decl ${__check_decl_arg} $(subst :, ,${i}))
ifneq (${HAVE_${ONE}${n}.${SUFFIX}},)
ifeq ($(filter ${i},${MKC_REQUIRE_${ONE}S${n}}),)
SUFFIX := $(call make_suffix,$(call toupper,${i}))
$(eval MKC_CFLAGS += -DHAVE_${ONE}${n}_${SUFFIX}=1)
endif
endif
endif
endef

define check_require_one
SUFFIX := $(call make_suffix,${i})
ifeq (${HAVE_${ONE}${n}.${SUFFIX}},)
_fake != env ${mkc.environ} mkc_check_decl -d ${one}${n} $(subst :, ,${i}) && echo
MKC_ERR_MSG +=	"ERROR: cannot find declaration of ${one} ${i}"
endif
endef

# checking one, ex. HAVE_DEFINES
define loop_one
ONE := $(call toupper,${one})
$(foreach i,${MKC_CHECK_${ONE}S${n}} ${MKC_REQUIRE_${ONE}S${n}},\
	$(eval $(value check_have_one)))

$(foreach i,${MKC_REQUIRE_${ONE}S${n}},$(eval $(value check_require_one)))

undefine MKC_CHECK_${ONE}S${n}
undefine MKC_REQUIRE_${ONE}S${n}
endef

# for defines, types, vars, funcs
define make_suffix
$(subst /,_,$(subst :,.,$(subst .,_,${1})))
endef

n :=
ONES_TO_CHECK := define type var
$(foreach one,${ONES_TO_CHECK},$(eval $(value loop_one)))

#for funcs
one := func
$(foreach n,0 1 2 3 4 5 6 7 8 9,$(eval $(value loop_one)))

#for members
define make_suffix
$(subst -,_,$(subst /,_,$(subst :,.,$(subst .,_,${1}))))
endef

#no sense for foreach
one := member
$(eval $(value loop_one))


######################################################
# custom checks
define check_custom

ifndef CUSTOM.${c}
ifndef MKC_CUSTOM_FN.${c}
MKC_CUSTOM_FN.${c} := ${c}.c
endif
ifeq ($(filter /%,${MKC_CUSTOM_FN.${c}}),)
MKC_CUSTOM_FN.${c} := ${MKC_CUSTOM_DIR}/${MKC_CUSTOM_FN.${c}}
endif
ifeq (${c},endianess)
$(warning endianess test deprecated; use endianness instead)
endif
CUSTOM.${c} != env ${mkc.environ} mkc_check_custom ${MKC_CUSTOM_FN.${c}}
endif #ifndef CUSTOM.${c}

ifneq (${CUSTOM.${c}},)
ifneq (${CUSTOM.${c}},0)
ifeq ($(filter ${c},${MKC_REQUIRE_CUSTOM}),)
MKC_CFLAGS  +=		-DCUSTOM_$(call toupper,${c})=${CUSTOM.${c}}
endif
endif
endif

endef

define check_require_custom
#.if empty(CUSTOM.${c}) || ${CUSTOM.${c}} == 0
ifeq ($(if $(call seq,${CUSTOM.${c}},0),,${CUSTOM.${c}}),)
_fake   !=   env ${mkc.environ} mkc_check_custom -d ${MKC_CUSTOM_FN.${c}} && echo
MKC_ERR_MSG +=		"ERROR: custom test ${c} failed"
endif
endef

$(foreach c,${MKC_CHECK_CUSTOM} ${MKC_REQUIRE_CUSTOM},\
	$(eval $(value check_custom)))

$(foreach c,${MKC_REQUIRE_CUSTOM},\
	$(eval $(value check_require_custom)))

$(foreach c,${MKC_CHECK_BUILTINS}, $(eval \
BUILTIN.${c} :=		${CUSTOM.${c}} \
))

######################################################
# checking for programs

define check_progs

_varname := MKC_PROG_id.$(subst +,x,${p})
ifdef ${_varname}
prog_id := ${_varname}
else
prog_id := $(subst /,_,${p})
endif

ifdef PROG.${prog_id}
else ifneq ($(filter /%,${p}),)
PROG.${prog_id} := ${p}
else
PROG.${prog_id} != env ${mkc.environ} mkc_check_prog -i '${prog_id}' '${p}'
endif

ifndef HAVE_PROG.${prog_id}
ifneq ($(and $(strip ${PROG.${prog_id}}),$(shell which ${PROG.${prog_id}} 2>/dev/null)),)
HAVE_PROG.${prog_id} := 1
else
HAVE_PROG.${prog_id} := 0
endif
endif

ifeq (${HAVE_PROG.${prog_id}},0)
ifneq ($(filter ${p},${MKC_REQUIRE_PROGS}),)
_fake   !=   env ${mkc.environ} mkc_check_prog -d -i '${prog_id}' '${p}' && echo
MKC_ERR_MSG +=	"ERROR: cannot find program ${p}"
endif
endif

endef

$(foreach p,${MKC_CHECK_PROGS} ${MKC_REQUIRE_PROGS},\
	$(eval $(value check_progs)))

undefine MKC_CHECK_PROGS
undefine MKC_REQUIRE_PROGS

undefine MKC_CHECK_CUSTOM
undefine MKC_REQUIRE_CUSTOM

######################################################
# checks whether $CC accepts some arguments

define check_cc_opts
ifndef HAVE_CC_OPT.$(subst =,_,${a})
aQ := $(call shell-quote,${a})
HAVE_CC_OPT.$(subst =,_,${a}) != env ${mkc.environ} CARGS=${aQ} mkc_check_custom -b -e -p cc_option -n ${aQ} -m 'whether ${CC} supports option '${aQ} ${BUILTINSDIR}/easy.c
endif
endef

$(foreach a,${MKC_CHECK_CC_OPTS},$(eval $(value check_cc_opts)))

define check_cxx_opts
ifndef HAVE_CXX_OPT.$(subst =,_,${a})
aQ := $(call shell-quote,${a})
HAVE_CXX_OPT.$(subst =,_,${a}) != env ${mkc.environ} CARGS=${aQ} mkc_check_custom -b -e -p cxx_option -n ${aQ} -m 'whether ${CXX} supports option '${aQ} ${BUILTINSDIR}/easy.cc
endif
endef

$(foreach a,${MKC_CHECK_CXX_OPTS},$(eval $(value check_cxx_opts)))

######################################################
# prototype checks

define check_prototypes
ifndef HAVE_PROTOTYPE.${p}
HAVE_PROTOTYPE.${p} != env ${mkc.environ} mkc_check_decl prototype \
	$(call shell-quote,${MKC_PROTOTYPE_FUNC.${p}}) \
	${MKC_PROTOTYPE_HEADERS.${p}}
endif

ifeq (HAVE_PROTOTYPE.${p},1)
MKC_CFLAGS  +=	-DHAVE_PROTOTYPE_$(call toupper,${p})=1
else ifneq ($(call filter-glob,${p},${MKC_REQUIRE_PROTOTYPES}),)
_fake       !=	env ${mkc.environ} mkc_check_decl -d prototype \
	            $(call shell-quote,${MKC_PROTOTYPE_FUNC.${p}}) \
		    ${MKC_PROTOTYPE_HEADERS.${p}}; echo
MKC_ERR_MSG +=		"ERROR: prototype test ${p} failed"
endif
endef

$(foreach p,${MKC_CHECK_PROTOTYPES} ${MKC_REQUIRE_PROTOTYPES},\
	$(eval $(value check_prototypes)))

undefine MKC_CHECK_PROTOTYPES
undefine MKC_REQUIRE_PROTOTYPES

######################################################
else # MKCHECKS == yes

# for changing CLEANFILES
$(eval MKC_SRCS += ${_MKC_SOURCE_FUNCS})

endif # MKCHECKS?

######################################################
# final assignments
include mkc_imp.conf-final.mk

######################################################
######################################################
######################################################

undefine MKC_SOURCE_FUNCLIBS
