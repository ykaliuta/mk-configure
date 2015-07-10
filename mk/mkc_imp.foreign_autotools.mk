# Copyright (c) 2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_FOREIGN_AUTOTOOLS_MK
_MKC_IMP_FOREIGN_AUTOTOOLS_MK := 1

MESSAGE.atconf ?=	@${_MESSAGE} "CONFIGURE:"
MESSAGE.autotools ?=	@${_MESSAGE} "AUTOTOOLS:"

MKC_REQUIRE_PROGS +=	autoreconf

AT_USE_AUTOMAKE ?=	yes
AT_MAKE         ?=	${MAKE}
AT_AUTORECONF_ARGS ?=	-is -f

ifeq (${FSRCDIR},)
MKC_ERR_MSG +=	"FSRCDIR should not be empty"
else ifeq ($(filter /%,${FSRCDIR}),)
_FSRCDIR = ${CURDIR}/${FSRCDIR}
else
_FSRCDIR = ${FSRCDIR}
endif

ifeq (${.OBJDIR},${CURDIR})
OBJDIR  =	${_FSRCDIR}
endif
_FOBJDIR =	${.OBJDIR}

_CONFIGURE_ARGS = --prefix ${PREFIX} --bindir=${BINDIR} \
   --sbindir=${SBINDIR} --libexecdir=${LIBEXECDIR} \
   --sysconfdir=${SYSCONFDIR} --sharedstatedir=${SHAREDSTATEDIR} \
   --localstatedir=${VARDIR} --libdir=${LIBDIR} \
   --includedir=${INCSDIR} --datarootdir=${DATADIR} \
   --infodir=${INFODIR} --localedir=${DATADIR}/locale \
   --mandir=${MANDIR} --docdir=${DATADIR}/doc/${PROJECTNAME} \
   --srcdir=${_FSRCDIR} ${AT_CONFIGURE_ARGS}

_CONFIGURE_ENV = CC=${CC} CFLAGS=${CFLAGS} \
   CXX=${CXX} CXXFLAGS=${CXXFLAGS} \
   CPPFLAGS=${_CPPFLAGS} \
   LDFLAGS=${LDFLAGS} LIBS=${LDADD} CPP=${CPP} ${AT_CONFIGURE_ENV}

_AT_MAKE_ENV = ${DESTDIR:DDESTDIR=${DESTDIR}} ${AT_MAKE_ENV}

realdo_mkgen:
	${MESSAGE.mkgen}
	${_V} ${PROG.autoreconf} ${AT_AUTORECONF_ARGS} ${_FSRCDIR}

at_do_errorcheck: check_mkc_err_msg
realdo_errorcheck: check_mkc_err_msg at_do_errorcheck

.PHONY: at_do_errorcheck
at_do_errorcheck:
	${MESSAGE.atconf}
	${_V} cd ${_FOBJDIR}; env ${_CONFIGURE_ENV} ${_FSRCDIR}/configure ${_CONFIGURE_ARGS}

_tmp_targets = all clean cleandir install uninstall
.PHONY: $(addprefix realdo_,${_tmp_targets})
$(addprefix realdo_,${_tmp_targets}): realdo_%: at_do_%
.PHONY: $(addprefix at_do_,${_tmp_targets})
$(addprefix at_do_,${_tmp_targets}): at_do_%:
	${MESSAGE.autotools}
	${_V} set -e; \
	cd ${_FOBJDIR}; \
	if test -f Makefile; then \
	    env ${_AT_MAKE_ENV} ${AT_MAKE} ${AT_MAKEFLAGS} \
		$(subst cleandir,distclean,$*); \
	fi

DISTCLEANDIRS  +=	${_FSRCDIR}/autom4te.cache
DISTCLEANFILES +=	${_FSRCDIR}/aclocal.m4 ${_FOBJDIR}/config.log \
   ${_FOBJDIR}/config.status ${_FSRCDIR}/configure ${_FSRCDIR}/depcomp \
   ${_FSRCDIR}/INSTALL ${_FSRCDIR}/install-sh ${_FOBJDIR}/Makefile \
   ${_FSRCDIR}/missing ${_FSRCDIR}/compile ${_FOBJDIR}/stamp-h1

ifeq ($(call tolower,${AT_USE_AUTOMAKE}),yes)
DISTCLEANFILES    +=	${_FSRCDIR}/Makefile.in
MKC_REQUIRE_PROGS +=	automake
endif

endif # _MKC_IMP_FOREIGN_AUTOTOOLS_MK
