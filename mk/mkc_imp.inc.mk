# Copyright (c) 2009-2010 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

do_install1:	incinstall
.PHONY: incinstall
incinstall: # ensure existence

ifdef INCS
INCSSRCDIR  ?=	.
CPPFLAGS0   +=	-I${INCSSRCDIR}

ifeq ($(call tolower,${MKINSTALL}),yes)
destination_incs = $(addprefix ${DESTDIR}${INCSDIR}/,${INCS})

incinstall: ${destination_incs}
.PRECIOUS: ${destination_incs}
.PHONY: ${destination_incs}

__incinstall = \
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} \
	    -o ${BINOWN} \
	    -g ${BINGRP} -m ${NONBINMODE} $^ $@

_tmp_prefix := ${DESTDIR}${INCSDIR}/
_tmp_targets := $(addprefix ${_tmp_prefix},${INCS})

ifneq (${INCSSRCDIR},.)
_tmp_dep_prefix := ${INCSSRCDIR}/
else
_tmp_dep_prefix :=
endif

$(_tmp_targets): ${_tmp_prefix}%: ${_tmp_dep_prefix}%
	${__incinstall}

UNINSTALLFILES  +=	${destination_incs}
INSTALLDIRS     +=	$(dir ${destination_incs})
endif # MKINSTALL
endif # INCS
