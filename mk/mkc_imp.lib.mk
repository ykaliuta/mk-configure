# Copyright (c) 2009-2014 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_LIB_MK
_MKC_IMP_LIB_MK := 1

.PHONY:		libinstall
ifeq ($(call tolower,${MKINSTALL}),yes)
do_install1:	libinstall
INSTALLDIRS    +=	${DESTDIR}${LIBDIR}
UNINSTALLFILES +=	${UNINSTALLFILES.lib}
endif # MKINSTALL

# Set PICFLAGS to cc flags for producing position-independent code,
# if not already set.  Includes -DPIC, if required.

# Data-driven table using make variables to control how shared libraries
# are built for different platforms and object formats.
# OBJECT_FMT:		currently either "ELF" or "a.out", from <bsd.own.mk>
# LDFLAGS.soname:	Flags to tell ${LD} to emit shared library.
#			with ELF, also set shared-lib version for ld.so.
#
# FFLAGS.pic:		flags for ${FC} to compile .[fF] files to .os objects.
# CPPICFLAGS:		flags for ${CPP} to preprocess .[sS] files for ${AS}
# CFLAGS.pic:		flags for ${CC} to compile .[cC] files to .os objects.
# CAFLAGS.pic		flags for {$CC} to compiling .[Ss] files
#		 	(usually just ${CPPFLAGS.pic} ${CFLAGS.pic})
# AFLAGS.pic:		flags for ${AS} to assemble .[sS] to .os objects.

CFLAGS  +=	${COPTS}
FFLAGS  +=	${FOPTS}


OBJS  +=	$(addsuffix .o,\
			$(basename $(notdir $(filter-out %.h %.sh,${SRCS}))))
SOBJS  =	${OBJS:.o=.os}
POBJS  =	${OBJS:.o=.op}

SRC_PATHADD +=	$(filter-out ./,$(dir $(filter-out %.h %.sh,${SRCS})))

ifneq ($(call tolower,${MKSTATICLIB}),no)
_LIBS +=	lib${LIB}.a
endif

ifneq ($(call tolower,${MKPROFILELIB}),no)
_LIBS +=	lib${LIB}_p.a
endif

ifneq ($(call tolower,${MKPICLIB}),no)
_LIBS +=	lib${LIB}_pic.a
endif # MKPICLIB

ifneq ($(call tolower,${MKSHLIB}),no)
ifeq ($(call tolower,${MKDLL}),no)
SHLIBFN  =	lib${LIB}${SHLIB_EXTFULL}
else
SHLIBFN  =	${LIB}${DLL_EXT}
endif
_LIBS   +=	${SHLIBFN}
endif

#TODO
#.NOPATH: ${_LIBS}

realdo_all: ${SRCS} ${_LIBS}

_SRCS_ALL = ${SRCS}

define __archivebuild
	@${RM} -f ${.TARGET}
	${MESSAGE.ar}
	${_V} ${AR} cq ${.TARGET} ${.ALLSRC}; \
	${RANLIB} ${.TARGET}
endef

define __archiveinstall
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} -o ${LIBOWN} \
	    -g ${LIBGRP} -m ${LIBMODE} ${.ALLSRC} ${.TARGET}
endef

DPSRCS     += $(patsubst %.l,%.c,$(filter %.l,${SRCS}))
DPSRCS     += $(patsubst %.y,%.c,$(filter %.y,${SRCS}))
CLEANFILES +=	${DPSRCS}
ifdef YHEADER
CLEANFILES +=	$(patsubst %.y,%.h,$(filter %.y,${SRCS}))
endif

lib${LIB}.a:: ${OBJS}
	${__archivebuild}
	@${_MESSAGE_V} "building standard ${LIB} library"

lib${LIB}_p.a:: ${POBJS}
	${__archivebuild}
	@${_MESSAGE_V} "building profiled ${LIB} library"

lib${LIB}_pic.a:: ${SOBJS}
	${__archivebuild}
	@${_MESSAGE_V} "building shared object ${LIB} library"

${SHLIBFN}: ${SOBJS} ${DPADD}
#TODO
#.if !commands(${SHLIBFN})
	@${_MESSAGE_V} building shared ${LIB} library \(version ${SHLIB_FULLVERSION}\)
	@${RM} -f ${.TARGET}
	@${_MESSAGE} "LD: ${.TARGET}"
	${_V} $(LDREAL) ${LDFLAGS.shlib} -o ${.TARGET} \
	    ${SOBJS} ${LDFLAGS0} ${LDADD0} ${LDFLAGS} ${LDADD}
ifeq (${OBJECT_FMT},ELF)
ifeq ($(call tolower,${MKDLL}),no)
	@${LN_S} -f ${SHLIBFN} lib${LIB}${SHLIB_EXT}
	@${LN_S} -f ${SHLIBFN} lib${LIB}${SHLIB_EXT1}
endif
endif # ELF
#.endif # !commands(...)

CLEANFILES += \
	${OBJS} ${POBJS} ${SOBJS}

ifeq ($(filter libinstall,${MAKECMDGOALS}),)
# Make sure it gets defined
libinstall::

CLEANFILES   +=	lib${LIB}.a lib${LIB}_pic.a lib${LIB}_p.a

   # MKSTATICLIB
ifneq ($(call tolower,${MKSTATICLIB}),no)
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}.a
UNINSTALLFILES.lib +=	${DESTDIR}${LIBDIR}/lib${LIB}.a

${DESTDIR}${LIBDIR}/lib${LIB}.a: lib${LIB}.a
	$(__archiveinstall)
endif

   # MKPROFILELIB
ifneq ($(call tolower,${MKPROFILELIB}),no)
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}_p.a
UNINSTALLFILES.lib +=	${DESTDIR}${LIBDIR}/lib${LIB}_p.a

${DESTDIR}${LIBDIR}/lib${LIB}_p.a: lib${LIB}_p.a
	${__archiveinstall}
endif

   # MKPICLIB
ifneq ($(call tolower,${MKPICLIB}),no)
libinstall:: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
.PRECIOUS: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
.PHONY: ${DESTDIR}${LIBDIR}/lib${LIB}_pic.a
UNINSTALLFILES.lib +=	${DESTDIR}${LIBDIR}/lib${LIB}_pic.a

${DESTDIR}${LIBDIR}/lib${LIB}_pic.a: lib${LIB}_pic.a
	${__archiveinstall}
endif

   # MKSHLIB
ifneq ($(call tolower,${MKSHLIB}),no)
libinstall:: ${DESTDIR}${LIBDIR}/${SHLIBFN}
.PRECIOUS: ${DESTDIR}${LIBDIR}/${SHLIBFN}
.PHONY: ${DESTDIR}${LIBDIR}/${SHLIBFN}
UNINSTALLFILES.lib += ${DESTDIR}${LIBDIR}/${SHLIBFN}

ifeq ($(call tolower,${MKDLL}),no)
UNINSTALLFILES.lib +=	${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT} \
			${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT1}
CLEANFILES += \
	lib${LIB}${SHLIB_EXT} lib${LIB}${SHLIB_EXT1} \
	lib${LIB}${SHLIB_EXT2} \
	$(if ${SHLIB_EXT3},lib${LIB}${SHLIB_EXT3})
else
CLEANFILES += ${SHLIBFN}
endif

${DESTDIR}${LIBDIR}/${SHLIBFN}: ${SHLIBFN}
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} -o ${LIBOWN} \
	    -g ${LIBGRP} -m ${SHLIBMODE} ${.ALLSRC} ${.TARGET}

ifeq (${OBJECT_FMT},a.out)
ifndef DESTDIR
ifeq ($(call tolower,${MKDLL}),no)
	/sbin/ldconfig -m ${LIBDIR}
endif
endif
endif

ifeq (${OBJECT_FMT},ELF)
ifeq ($(call tolower,${MKDLL}),no)
	${LN_S} -f ${SHLIBFN} \
	    ${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT1}
	${LN_S} -f ${SHLIBFN} \
	    ${DESTDIR}${LIBDIR}/lib${LIB}${SHLIB_EXT}
endif
endif #ELF

endif #MKSHLIB
endif # goal libinstall

endif #_MKC_IMP_LIB_MK
