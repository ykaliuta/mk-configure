# Copyright (c) 2009-2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifdef PKG_CONFIG_DEPS # PKG_CONFIG_DEPS -- deprecated 2014.01.15
MKC_REQUIRE_PKGCONFIG +=	${PKG_CONFIG_DEPS}
endif
ifdef MKC_REQUIRE_PKGCONFIG
MKC_CHECK_PKGCONFIG +=		${MKC_REQUIRE_PKGCONFIG}
endif

#.if defined(MKC_CHECK_PKGCONFIG) && !make(clean) && !make(cleandir) && !make(distclean)

ifdef MKC_CHECK_PKGCONFIG
ifeq ($(filter ${CLEAN_TARGETS},${MAKECMGGOALS}),)

MKC_REQUIRE_PROGS+=	pkg-config
include mkc_imp.conf-cleanup.mk

ifeq (${HAVE_PROG.pkg-config},1)

# $(1) l
define mkc_check_pkgconfig_loop

_lpair  =	$(call sed,s/\(>=\|<=\|=\|>\|<\)/ \1 /g,$(1))
_id     =	$$(firstword $${_lpair})
_varname = PCNAME.$$(subst -,_,$$(subst +,p,$$(subst .,_,$${id})))
ifdef $$(_varname)
_pcname = $${$${_varname}}
else
_pcname = $${_id}
endif
_lp    :=	$${_pcname} $$(word 2, $${_lpair}) $$(word 3 $${_lpair})
_ln	=	$$(subst >=,_ge_,$$(subst >,_gt_,$$(subst <=,_le_,$$(subst <,_lt_,$$(subst =,_eq_,$(1))))))

PKG_CONFIG.exists.$${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -s -n '$${_ln}' -m '[pkg-config] $${_lp}' \
    ${PROG.pkg-config} --print-errors --exists "$${_lp}"

ifneq ($${PKG_CONFIG.exists.$${_ln}},)
# --cflags and --libs
ifneq ($(strip $(filter-out undefined,$(origin PROGS) $(origin LIB))),)
ifndef CPPFLAGS.pkg-config.$${_ln}
CPPFLAGS.pkg-config.$${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '$${_ln}_cflags' -m '[pkg-config] $${_lp} --cflags' \
    ${PROG.pkg-config} --cflags "${_lp}"
endif # CPPFLAGS.pkg-config.${l}

ifndef LDADD.pkg-config.$${_ln}
LDADD.pkg-config.$${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '$${_ln}_libs' -m '[pkg-config] $${_lp} --libs' \
    ${PROG.pkg-config} --libs "$${_lp}"
endif # LDADD.pkg-config.${l}

MKC_CPPFLAGS :=	${MKC_CPPFLAGS} $${CPPFLAGS.pkg-config.$${_ln}}
MKC_LDADD    :=	${MKC_LDADD} $${LDADD.pkg-config.$${_ln}}
endif # PROGS || LIB

$$(foreach i,$${PKG_CONFIG_VARS.$${_ln}},\
	$$(eval $$(call pkg_config_vars_loop,$${i})))

MKC_CFLAGS := ${MKC_CFLAGS} \
	-DHAVE_PKGCONFIG_$$(subst -,_,$$(subst +,P,$$(subst .,_,$${_id})))=1

#!empty(MKC_REQUIRE_PKGCONFIG:M${l})
else ifneq ($(call filter-glob,$(1),${MKC_REQUIRE_PKGCONFIG}),)
MKC_ERR_MSG := ${MKC_ERR_MSG} "%%%: ${MKC_CACHEDIR}/_mkc_pkgconfig_$${_ln}.err"
endif # PKG-CONFIG.exists
endef

# $(1) i
define pkg_config_vars_loop
ifndef PKG_CONFIG.var.${_ln}.$(1))
PKG_CONFIG.var.${_ln}.$(1) != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '${_ln}_$(1)' -m '[pkg-config] ${_lp} --variable=$(1)' \
    ${PROG.pkg-config} --variable=${i} "${_lp}"
endif # PKG_CONFIG.var.${_ln}.${i}
endef

$(foreach l,$(sort ${MKC_CHECK_PKGCONFIG}),$(eval $(call mkc_check_pkgconfig_loop ${l})))

######################################################
include mkc_imp.conf-final.mk

undefine PKG_CONFIG_DEPS
undefine MKC_CHECK_PKGCONFIG
undefine MKC_REQUIRE_PKGCONFIG

undefine _lpair
undefine _id
undefine _pcname
undefine _lp
undefine _ln

endif # HAVE_PROG.pkg-config

endif # !make(clean) && !make(cleandir) && !make(distclean)
endif # ifdef MKC_CHECK_PKGCONFIG

