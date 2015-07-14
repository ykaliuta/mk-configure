# Copyright (c) 2009-2014 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
# Copyright (c) 2009-2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

include mkc.gmake.mk

ifndef OPSYS
OPSYS !=	uname -s
OPSYS :=	$(patsubst CYGWIN%,Cygwin,${OPSYS})
endif
TARGET_OPSYS ?=	${OPSYS}

###########
SHORTPRJNAME   ?=	yes

######################################################################
ifndef __initialized__
__initialized__ := 1

include mkc_imp.preinit.mk

.DEFAULT_GOAL := all

###########
-include mkc_imp.vars.mk # .sinclude for bootstrapping

#.if defined(MKC_SHELL)
#.SHELL: name=${MKC_SHELL}
#.elif ${OPSYS} == "SunOS"
#.SHELL: name=/usr/xpg4/bin/sh
#.endif

###########

# SRCS may be changed by mkc_imp.conf.mk
$(foreach p,${PROGS},$(eval \
SRCS.${p} ?=	${p}.c \
SRCS.${p} +=	${SRCS}  \
_srcsall +=	${SRCS.${p}}))

ifdef PROG
PROGS         ?=	${PROG}
SRCS          ?=	${PROG}.c
SRCS.${PROG}  ?=	${SRCS}
_srcsall +=	${SRCS}
else ifeq ($(notdir ${.CURDIR}),${COMPATLIB})
SRCS     ?=	${FEATURESDIR}/_mkcfake.c
_srcsall +=	${SRCS}
else ifdef LIB
SRCS     ?=	${LIB}.c
_srcsall +=	${SRCS}
endif # defined(PROG)

ifneq ($(filter %.cxx %.cpp %.C %.cc,${_srscall}),)
src_type   +=	cxx
LDREAL     ?=	${CXX}
else ifneq ($(filter %.pas %.p,${_srcsall}),)
src_type   +=	pas
LDREAL     ?=	${PC}
endif

# last was actually defined(MKC_SOURCE_FUNCLIBS)
ifneq ($(or $(filter %.c %.l %.y,${_srcsall})),${MKC_SOURCE_FUNCLIBS},)
src_type  +=	c
endif

src_type  ?=	0

LDREAL  ?=	${CC}

ifdef PROGS
LDREAL  ?=	${CC}
else
LDREAL  ?=	${LD}
endif

# directory for cache and intermediate files
MKC_CACHEDIR ?=	${.OBJDIR}

# for mkc_imp.conf.mk
init_make_level ?= 0

ifeq (${MAKELEVEL},${init_make_level})
SRCTOP       ?=	${.CURDIR}
OBJTOP       ?=	${.OBJDIR}
export SRCTOP
export OBJTOP
endif

###########

PROJECTNAME ?= $(or ${PROG},${LIB},$(nodir ${CURDIR}))

ifneq ($(wildcard ${MAKECONF}),)
include "${MAKECONF}"
else ifdef MKC_SYSCONFDIR
ifneq ($(wildcard ${MKC_SYSCONFDIR}/mk-c.conf),)
include "${MKC_SYSCONFDIR}/mk-c.conf"
endif
else ifdef MKC_SYSCONFDIR
ifneq ($(wildcard ${MKC_SYSCONFDIR}/mk.conf),)
include "${MKC_SYSCONFDIR}/mk.conf"
endif
endif

ifeq (${OPSYS},SunOS)
_MKC_USER   !=	/usr/xpg4/bin/id -un
_MKC_GROUP  !=	/usr/xpg4/bin/id -gn
else
_MKC_USER   !=	id -un
_MKC_GROUP  !=	id -gn
endif

ifneq (${_MKC_USER},root)
ifneq (${OPSYS}${_MKC_USER},InterixAdministrator)
ROOT_USER  ?=	${_MKC_USER}
ROOT_GROUP ?=	${_MKC_GROUP}
endif
endif

BINGRP     ?=	${ROOT_GROUP}
BINOWN     ?=	${ROOT_USER}

SHLIBMODE.HP-UX    =	${BINMODE}
SHLIBMODE.OSF1     =	${BINMODE}
SHLIBMODE.Interix  =	${BINMODE}
SHLIBMODE         ?=	$(or ${SHLIBMODE.${TARGET_OPSYS}},${NONBINMODE})

ROOT_GROUP.NetBSD    =	wheel
ROOT_GROUP.OpenBSD   =	wheel
ROOT_GROUP.FreeBSD   =	wheel
ROOT_GROUP.Darwin    =	wheel
ROOT_GROUP.DragonFly =	wheel
ROOT_GROUP.MirBSD    =	wheel
ROOT_GROUP.HP-UX     =	bin
ROOT_GROUP.OSF1      =	bin
ROOT_GROUP.Interix   =	+Administrators
ROOR_GROUP.Haiku     =	root

ROOT_USER.HP-UX   =	bin
ROOT_USER.OSF1    = 	bin
ROOT_USER.Interix =	Administrator
ROOT_USER.Haiku   =	user

ROOT_USER  ?=		$(or ${ROOT_USER.${OPSYS}},root)
ROOT_GROUP ?=		$(or ${ROOT_GROUP.${OPSYS}},root)

BINMODE.Interix.Administrator    =	775
NONBINMODE.Interix.Administrator =	664

BINMODE    ?=		$(or ${BINMODE.${TARGET_OPSYS}.${ROOT_USER}},755)
NONBINMODE ?=		$(or ${BINMODE.${TARGET_OPSYS}.${ROOT_USER}},644)
DIRMODE    ?=		${BINMODE}

MANGRP     ?=	${ROOT_GROUP}
MANOWN     ?=	${ROOT_USER}
MANMODE    ?=	${NONBINMODE}
MANINSTALL ?=	maninstall catinstall

INFOGRP    ?=	${ROOT_GROUP}
INFOOWN    ?=	${ROOT_USER}
INFOMODE   ?=	${NONBINMODE}

LIBGRP     ?=	${BINGRP}
LIBOWN     ?=	${BINOWN}
LIBMODE    ?=	${NONBINMODE}

DOCGRP     ?=	${ROOT_GROUP}
DOCOWN     ?=	${ROOT_USER}
DOCMODE    ?=	${NONBINMODE}

FILESOWN   ?=	${BINOWN}
FILESGRP   ?=	${BINGRP}
FILESMODE  ?=	${NONBINMODE}

SCRIPTSOWN  ?=	${BINOWN}
SCRIPTSGRP  ?=	${BINGRP}
SCRIPTSMODE ?=	${BINMODE}

COPY        ?=		-c
PRESERVE    ?=
STRIPFLAG   ?=	-s

MKINSTALL ?=	yes

MKCATPAGES ?=	no
MKHTML     ?=	no
MKDOC      ?=	yes
MKINFO     ?=	yes
MKMAN      ?=	yes
MKSHARE    ?=	yes

#
# MKOBJDIRS controls whether object dirs are created during "make all" or "make obj".
#
MKOBJDIRS    ?=	auto
MKRELOBJDIR  ?=	no

MKINSTALLDIRS   ?=	yes

DISTCLEANFILES  +=	${MKC_CACHEDIR}/_mkc_*

MKDLL     ?=	no
ifeq ($(call tolower,${MKDLL}),only)
MKDLL      =	yes
MKSTATICLIB ?=	no
else
MKSTATICLIB ?=	yes
endif # MKDLL

ifneq ($(filter $(notdir ${CURDIR}),${STATICLIBS}),)
MKPICLIB     ?=	yes
else
MKPICLIB     ?=	no
endif

SHLIB_MINOR ?=	0
ifneq ($(call tolower,${MKDLL}),no)
SHLIB_MAJOR ?=	1
endif # MKDLL

MKPROFILELIB    ?=	no

ifdef SHLIB_MAJOR
ifeq ($(filter $(notdir ${CURDIR}),${STATICLIBS}),)
MKSHLIB  ?=	yes
endif
endif # SHLIB_MAJOR
# else
MKSHLIB  ?=	no

include mkc_imp.platform.sys.mk

AR         ?=	ar
ARFLAGS    ?=	rl
RANLIB     ?=	ranlib
MESSAGE.ar ?=	@${_MESSAGE} "AR: ${.TARGET}"

AS        ?=	as
AFLAGS    ?=
COMPILE.s ?=	${_V} ${CC_PREFIX} ${CC} ${AFLAGS} -c
MESSAGE.s ?=	@${_MESSAGE} "AS: ${.IMPSRC}"

CC        ?=	cc
CFLAGS    ?=
COMPILE.c ?=	${_V} ${CC_PREFIX} ${CC} ${CFLAGS} ${_CPPFLAGS} ${_CFLAGS.ssp} ${_CFLAGS.pie} ${CFLAGS.warns} -c
MESSAGE.c ?=	@${_MESSAGE} "CC: ${.IMPSRC}"

CXX        ?=	c++
CXXFLAGS   +=	${CFLAGS}
COMPILE.cc ?=	${_V} ${CXX_PREFIX} ${CXX} ${CXXFLAGS} ${_CPPFLAGS} ${_CXXFLAGS.ssp} ${_CXXFLAGS.pie} ${CXXFLAGS.warns} -c
MESSAGE.cc ?=	@${_MESSAGE} "CXX: ${.IMPSRC}"

OBJC       ?=	${CC}
OBJCFLAGS  ?=	${CFLAGS}
COMPILE.m  ?=	${_V} ${OBJC} ${OBJCFLAGS} ${_CPPFLAGS} -c
MESSAGE.m  ?=	@${_MESSAGE} "OBJC: ${.IMPSRC}"

CPP        ?=	cpp
CPPFLAGS   ?=	

_CPPFLAGS   =	${CPPFLAGS0} ${CPPFLAGS}

FC         ?=	f77
FFLAGS     ?=	-O
RFLAGS     ?=
COMPILE.f  ?=	${_V} ${FC} ${FFLAGS} -c
MESSAGE.f  ?=	@${_MESSAGE} "FC: ${.IMPSRC}"
COMPILE.F  ?=	${_V} ${FC} ${FFLAGS} ${_CPPFLAGS} -c
MESSAGE.F  ?=	${MESSAGE.f}
COMPILE.r  ?=	${_V} ${FC} ${FFLAGS} ${RFLAGS} -c
MESSAGE.r  ?=	${MESSAGE.f}

MESSAGE.ld ?=	@${_MESSAGE} "LD: ${.TARGET}"

CLEANFILES_CMD ?=	${RM} -f
CLEANDIRS_CMD ?=	${RM} -rf

INSTALL    ?=	install
UNINSTALL  ?=	${RM} -f

LEX       ?=	lex
LFLAGS    ?=
LEX.l     ?=	${_V} ${LEX} ${LFLAGS}
MESSAGE.l ?=	@${_MESSAGE} "LEX: ${.IMPSRC}"

LD.SunOS  ?=	/usr/ccs/bin/ld
LD.OSF1   ?=	/usr/bin/ld
LD        ?=	$(or ${LD.${TARGET_OPSYS}},ld)
LDFLAGS   ?=

ifeq (${OPSYS},Haiku)
LN        ?=	ln -s
LN_S      ?=	ln -s
else
LN        ?=	ln
LN_S      ?=	${LN} -s
endif

LORDER    ?=	lorder

NM        ?=	nm

MKDIR     ?=	mkdir

PC        ?=	pc
PFLAGS    ?=
COMPILE.p ?=	${_V} ${PC} ${PFLAGS} ${_CPPFLAGS} -c
MESSAGE.p ?=	@${_MESSAGE} "PC: ${.IMPSRC}"

SHELL     ?=	sh

SIZE      ?=	size

TSORT     ?= 	tsort -q

YACC      ?=	yacc
YFLAGS    ?=
YACC.y    ?=	${_V} ${YACC} ${YFLAGS}
MESSAGE.y ?=	@${_MESSAGE} "YACC: ${.IMPSRC}"

MESSAGE.mkgen ?=	@${_MESSAGE} "MKGEN:"

TAR       ?=	tar
GZIP      ?=	gzip
BZIP2     ?=	bzip2
ZIP       ?=	zip

OBJCOPY   ?=    objcopy

OBJDUMP   ?=    objdump

STRIP     ?=	strip

RM        ?=	rm

TARGETS +=	all install clean cleandir depend test \
		installdirs uninstall errorcheck filelist obj mkgen
TARGETS :=	$(sort ${TARGETS})

ALLTARGETS +=	errorcheck all install clean cleandir depend uninstall installdirs \
  mkgen bin_tar bin_targz bin_tarbz2 bin_zip bin_deb

VERBOSE_ECHO ?=	echo

# short synonym
_PN =	${PROJECTNAME}
# Lex
LPREFIX ?=	yy
ifneq (${LPREFIX},yy)
LFLAGS +=	-P${LPREFIX}
endif
LEXLIB ?=	-ll

# Yacc
YFLAGS +=	$(if ${YPREFIX},-p${YPREFIX}) $(if ${YHEADER},-d)

EXPORT_VARNAMES +=	MKC_CACHEDIR TARGETS SHORTPRJNAME

EXPORT_DYNAMIC  ?=	no

INTERNALLIBS +=	${COMPATLIB}
STATICLIBS   +=	${INTERNALLIBS}

###########
-include ${SRCTOP}/Makefile.common

ifneq (${SRCTOP},${.CURDIR})
-include ${.CURDIR}/../Makefile.inc
endif

###########

PREFIX     ?=	/usr/local

BINDIR     ?=	${PREFIX}/bin
SBINDIR    ?=	${PREFIX}/sbin
FILESDIR   ?=	${PREFIX}/bin
LIBEXECDIR ?=	${PREFIX}/libexec
INCSDIR    ?=	${PREFIX}/include
DATADIR    ?=	${PREFIX}/share
SHAREDSTATEDIR    ?=	${PREFIX}/com
VARDIR     ?=	${PREFIX}/var
SYSCONFDIR ?=	${PREFIX}/etc
INFODIR    ?=	${PREFIX}/info
MANDIR     ?=	${PREFIX}/man
LIBDIR     ?=	${PREFIX}/lib
SCRIPTSDIR ?=	${BINDIR}

DOCDIR?     =	${DATADIR}/doc
HTMLDOCDIR ?=	${DOCDIR}/html
HTMLDIR    ?=	${MANDIR}

MKPIE     ?=	no
USE_SSP   ?=	no
USE_RELRO ?=	no
USE_FORT  ?=	no

######
ifeq ($(call tolower,${MKPIE}),yes)
LDFLAGS.prog +=	${LDFLAGS.pie}
_CFLAGS.pie   +=	${CFLAGS.pie}
_CXXFLAGS.pie +=	${CXXFLAGS.pie}
endif

ifeq ($(call tolower,${USE_SSP}),yes)
_CFLAGS.ssp   =	${CFLAGS.ssp}
_CXXFLAGS.ssp =	${CXXFLAGS.ssp}
endif

ifeq ($(call tolower,${USE_RELRO}),yes)
LDFLAGS.prog +=	${LDFLAGS.relro}
endif

ifeq ($(call tolower,${USE_FORT}),yes)
CPPFLAGS +=	-D_FORTIFY_SOURCE=2
CFLAGS   +=	-O
endif

SHRTOUT    ?=	no

ifneq ($(call tolower,${SHRTOUT}),no)
_MESSAGE   ?=	echo
_MESSAGE_V ?=	:
_V         ?=	@
else
_MESSAGE   ?=	:
_MESSAGE_V ?=	echo
_V         ?=
endif

###########

ifdef MKC_REQD
ifdef MKC_VERSION
_mkc_version_ok  !=	mkc_check_version ${MKC_REQD} ${MKC_VERSION}
ifneq (${_mkc_version_ok},1)
MKC_ERR_MSG +=	"ERROR: We need mk-configure v.${MKC_REQD} while ${MKC_VERSION} is detected"
MKCHECKS     =	no
endif
endif
endif

###########

endif # __initialized__
