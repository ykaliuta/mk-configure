# Copyright (c) 2009-2010 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_PROG_MK
_MKC_IMP_PROG_MK := 1

proginstall: # ensure existence
.PHONY: proginstall

CFLAGS +=	${COPTS}

__proginstall = \
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} ${STRIPFLAG} \
	    -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} ${.ALLSRC} ${.TARGET}

# need to evaluate progname in a variable
# ${1} -- progname
define __gen_prog_recipe
${1}: ${LIBCRT0} ${DPSRCS.${1}} ${OBJS.${1}} ${LIBC} ${LIBCRTBEGIN} ${LIBCRTEND} ${DPADD}
# TODO
#.if !commands(${p})
	$${MESSAGE.ld}
	$${_V}$${LDREAL} -o $${.TARGET} $${OBJS.${1}} \
	    $${LDFLAGS0} $${LDADD0} \
	    $${LDFLAGS} $${LDFLAGS.prog} $${LDADD}
#.endif # !commands(...)
endef

# ${p} is prog
define __gen_prog_rules
do_install1:	proginstall

_SRCS_ALL += ${SRCS.${p}}

DPSRCS.${p} := $(patsubst %.l,%.c,$(patsubst %.y,%.c,$(filter %.l %.y,${SRCS})))

$(eval CLEANFILES +=	${DPSRCS.${p}})
ifdef YHEADER
$(eval CLEANFILES += $(patsubst %.y,%.h,$(filter %.y,${SRCS})))
endif # defined(YHEADER)

OBJS.${p} :=	$(addsuffix .o,$(basename $(notdir $(filter-out %.h %.sh %.fth,${SRCS}))))

$(eval SRC_PATHADD += $(filter-out ./,$(dir $(filter-out %.h %.sh,${SRCS}))))

ifneq (${OBJS.${p}},)
# TODO
#.NOPATH: ${OBJS.${p}}

$(eval $(call __gen_prog_recipe,${p}))

endif	# defined(OBJS.${p}) && !empty(OBJS.${p})

ifndef MAN
ifneq ($(wildcard ${p}.1),)
$(eval MAN +=		${p}.1)
endif
endif # !defined(MAN)

$(eval PROGNAME.${p} ?=	$(or ${PROGNAME},${p}))

dest_prog.${p}   :=	${DESTDIR}${BINDIR}/${PROGNAME.${p}}
ifeq ($(call tolower,${MKINSTALL}),yes)
$(eval UNINSTALLFILES  +=	${dest_prog.${p}})
$(eval INSTALLDIRS     +=	$(dir ${dest_prog.${p}}))

proginstall: ${dest_prog.${p}}
.PRECIOUS:    ${dest_prog.${p}}
.PHONY:       ${dest_prog.${p}}
endif # ${MKINSTALL:tl} == "yes"

${DESTDIR}${BINDIR}/${PROGNAME.${p}}: ${p}
	${__proginstall}

$(eval CLEANFILES +=	${OBJS.${p}})

endef

$(foreach p,${PROGS},$(eval $(value __gen_prog_rules)))

realdo_all: ${PROGS}

CLEANFILES += ${PROGS}

endif # _MKC_IMP_PROG_MK
