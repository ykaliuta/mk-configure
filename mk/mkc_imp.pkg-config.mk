# Copyright (c) 2009-2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

.if defined(PKG_CONFIG_DEPS) # PKG_CONFIG_DEPS -- deprecated 2014.01.15
MKC_REQUIRE_PKGCONFIG +=	${PKG_CONFIG_DEPS}
.endif
.if defined(MKC_REQUIRE_PKGCONFIG)
MKC_CHECK_PKGCONFIG +=		${MKC_REQUIRE_PKGCONFIG}
.endif

.if defined(MKC_CHECK_PKGCONFIG) && !make(clean) && !make(cleandir) && !make(distclean)
MKC_REQUIRE_PROGS+=	pkg-config
.include <configure.mk>

.if ${HAVE_PROG.pkg-config}

.for l in ${MKC_CHECK_PKGCONFIG:O:u}
_lpair  =	${l:C/(>=|<=|=|>|<)/ & /g}
_id     =	${_lpair:[1]}
_pcname =	${PCNAME.${_id:S/-/_/g:S/+/p/g:S/./_/g}:U${_id}}
_lp    :=	${_pcname} ${_lpair:[2]} ${_lpair:[3]}
_ln     =	${l:S/>=/_ge_/:S/>/_gt_/:S/<=/_le_/:S/</_lt_/:S/=/_eq_/}

PKG_CONFIG.exists.${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -s -n '${_ln}' -m '[pkg-config] ${_lp}' \
    ${PROG.pkg-config} --print-errors --exists "${_lp}"

.if ${PKG_CONFIG.exists.${_ln}}
# --cflags and --libs
.if defined(PROGS) || defined(LIB)
.if !defined(CPPFLAGS.pkg-config.${_ln})
CPPFLAGS.pkg-config.${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '${_ln}_cflags' -m '[pkg-config] ${_lp} --cflags' \
    ${PROG.pkg-config} --cflags "${_lp}"
.endif # CPPFLAGS.pkg-config.${l}

.if !defined(LDADD.pkg-config.${_ln})
LDADD.pkg-config.${_ln} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '${_ln}_libs' -m '[pkg-config] ${_lp} --libs' \
    ${PROG.pkg-config} --libs "${_lp}"
.endif # LDADD.pkg-config.${l}

MKC_CPPFLAGS :=	${MKC_CPPFLAGS} ${CPPFLAGS.pkg-config.${_ln}}
MKC_LDADD    :=	${MKC_LDADD} ${LDADD.pkg-config.${_ln}}
.endif # PROGS || LIB

.for i in ${PKG_CONFIG_VARS.${_ln}}
.if !defined(PKG_CONFIG.var.${_ln}.${i})
PKG_CONFIG.var.${_ln}.${i} != env ${mkc.environ} mkc_check_custom \
    -p pkgconfig -n '${_ln}_${i}' -m '[pkg-config] ${_lp} --variable=${i}' \
    ${PROG.pkg-config} --variable=${i} "${_lp}"
.endif # PKG_CONFIG.var.${_ln}.${i}
.endfor # i

MKC_CFLAGS :=	${MKC_CFLAGS} -DHAVE_PKGCONFIG_${_id:S/-/_/g:S/+/P/g:S/./_/g}=1

.elif !empty(MKC_REQUIRE_PKGCONFIG:M${l})
MKC_ERR_MSG := ${MKC_ERR_MSG} "%%%: ${MKC_CACHEDIR}/_mkc_pkgconfig_${_ln}.err"
.endif # PKG-CONFIG.exists

.endfor # .for l in MKC_CHECK_PKGCONFIG

######################################################
.include <mkc_imp.conf-final.mk>

.undef PKG_CONFIG_DEPS
.undef MKC_CHECK_PKGCONFIG
.undef MKC_REQUIRE_PKGCONFIG

.undef _lpair
.undef _id
.undef _pcname
.undef _lp
.undef _ln

.endif # HAVE_PROG.pkg-config

.endif # !make(clean) && !make(cleandir) && !make(distclean)
