# Copyright (c) 2009-2010 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_MAN_MK
_MKC_IMP_MAN_MK := 1

MESSAGE.nroff ?=	@${_MESSAGE} "NROFF: ${.TARGET}"

ifeq ($(call tolower,${MKSHARE}),no)
MKCATPAGES =	no
MKDOC      =	no
MKINFO     =	no
MKMAN      =	no
endif

ifeq ($(call tolower,${MKMAN}),no)
MKCATPAGES =	no
endif

ifeq ($(call tolower,${USETBL}),no)
undefine USETBL
endif

ifeq ($(call tolower,${MANZ}),no)
undefine MANZ
endif

.PHONY:		catinstall maninstall catpages manpages catlinks \
		manlinks html installhtml
ifneq ($(call tolower,${MKMAN}),no)
do_install1:	${MANINSTALL}
endif

MANTARGET ?=	cat
NROFF     ?=	nroff
GROFF     ?=	groff
TBL       ?=	tbl

.SUFFIXES: .1 .2 .3 .4 .5 .6 .7 .8 .9 \
	   .cat1 .cat2 .cat3 .cat4 .cat5 .cat6 .cat7 .cat8 .cat9 \
	   .html1 .html2 .html3 .html4 .html5 .html6 .html7 .html8 .html9

.9.cat9 .8.cat8 .7.cat7 .6.cat6 .5.cat5 .4.cat4 .3.cat3 .2.cat2 .1.cat1:
	${MESSAGE.nroff}
ifndef USETBL
	${_V} ${NROFF} ${NROFF_MAN2CAT} ${.IMPSRC} > ${.TARGET} || \
	 (${RM} -f ${.TARGET}; false)
else
	${_V} ${TBL} ${.IMPSRC} | ${NROFF} ${NROFF_MAN2CAT} > ${.TARGET} || \
	 (${RM} -f ${.TARGET}; false)
endif

.9.html9 .8.html8 .7.html7 .6.html6 .5.html5 .4.html4 .3.html3 .2.html2 .1.html1:
ifndef USETBL
	@echo "${GROFF} -Tascii -mdoc2html -P-b -P-u -P-o ${.IMPSRC} > ${.TARGET}"
	@${GROFF} -Tascii -mdoc2html -P-b -P-u -P-o ${.IMPSRC} > ${.TARGET} || \
	 (${RM} -f ${.TARGET}; false)
else
	@echo "${TBL} ${.IMPSRC} | ${GROFF} -mdoc2html -P-b -P-u -P-o > ${.TARGET}"
	@cat ${.IMPSRC} | ${GROFF} -mdoc2html -P-b -P-u -P-o > ${.TARGET} || \
	 (${RM} -f ${.TARGET}; false)
endif

ifneq (${MAN},)
realdo_all: ${MAN}
MANPAGES    =	${MAN}
CATPAGES    =	$(call sed,s/(.*).([1-9])/\\1.cat\\2/,${MANPAGES})
CLEANFILES +=	${CATPAGES}
#TODO
#.NOPATH:	${CATPAGES}
HTMLPAGES   =	$(call sed,s/(.*).([1-9])/\\1.html\\2/,${MANPAGES})
endif

MINSTALL    =	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} \
		    -o ${MANOWN} -g ${MANGRP} -m ${MANMODE}

ifdef MANZ
# chown and chmod are done afterward automatically
MCOMPRESS       =	gzip -cf
MCOMPRESSSUFFIX =	.gz
endif

catinstall: catlinks
maninstall: manlinks

ifneq (${MCOMPRESS},)
define __installpage
	@${RM} -f ${.TARGET}
	${MCOMPRESS} ${.ALLSRC} > ${.TARGET}
	@chown ${MANOWN}:${MANGRP} ${.TARGET}
	@chmod ${MANMODE} ${.TARGET}
endef
else
define __installpage
	${MINSTALL} ${.ALLSRC} ${.TARGET}
endef
endif

catpages::

# Rules for cat'ed man page installation
ifneq (${CATPAGES},)
ifneq ($(call tolower,${MKCATPAGES}),no)

realdo_all: ${CATPAGES}

ifeq ($(call tolower,${MKINSTALL}),yes)

define gen_destcapage
    ${DESTDIR}${MANDIR}/$(suffix ${1})${MANSUBDIR}/$(basename $(notdir ${1})).0${MCOMPRESSSUFFIX}
endef

destination_capages = $(foreach P,${FILES},$(call gen_destcapage,${P}))

UNINSTALLFILES  +=	${destination_capages}
INSTALLDIRS     +=	$(dir ${destination_capages})
endif # MKINSTALL

catpages:: ${destination_capages}
.PRECIOUS: ${destination_capages}
.PHONY:    ${destination_capages}

define __gen_install_rule
$(call gen_destcapage,${P}): ${P}
	$(__installpage)
endef
$(foreach P,$(sort ${CATPAGES}),$(eval $(value __gen_install_rule)))

endif
endif # CATPAGES

# Rules for source page installation
manpages::

ifneq (${MANPAGES},)

ifeq ($(call tolower,${MKINSTALL}),yes)

__gen_dest_file = ${DESTDIR}${MANDIR}/man$(suffix ${1})${MANSUBDIR}/${1}${MCOMPRESSSUFFIX}

destination_manpages := $(foreach I,${MANPAGES},$(call __gen_dest_file,${I}))
UNINSTALLFILES  +=	${destination_manpages}
INSTALLDIRS     +=	$(dir ${destination_manpages})
endif # MKINSTALL

manpages:: ${destination_manpages}
.PRECIOUS: ${destination_manpages}
.PHONY:    ${destination_manpages}

define __gen_install_rule
$(call __gen_dest_file,${I}): ${I}
	${__installpage}
endef

$(foreach I,$(sort ${MANPAGES}),$(eval $(value __gen_install_rule)))

endif # MANPAGES

ifneq ($(call tolower,${MKCATPAGES}),no)

# ${1} source
# ${2} destination
define __process_mlink
$(eval \
LINKS += ${MANDIR}/cat$(suffix ${1})${MANSUBDIR}/$(basename $(notdir ${1})).0${MCOMPRESSSUFFIX} \
	     ${MANDIR}/cat$(suffix ${2})${MANSUBDIR}/$(basename $(notdir ${2})).0${MCOMPRESSSUFFIX}
UNINSTALLFILES += ${DESTDIR}${MANDIR}/cat$(suffix ${2})${MANSUBDIR}/$(basename $(notdir ${2})).0${MCOMPRESSSUFFIX}
)
endef

$(call process_pairs,__process_mlink,${MLINKS})

catlinks: catpages
endif
catlinks:

# ${1} source
# ${2} destination
define __process_mlink
$(eval \
LINKS += ${MANDIR}/cat$(suffix ${1})${MANSUBDIR}/${1}${MCOMPRESSSUFFIX} \
	   ${MANDIR}/cat$(suffix ${2})${MANSUBDIR}/${2}${MCOMPRESSSUFFIX}
UNINSTALLFILES += ${DESTDIR}${MANDIR}/cat$(suffix ${2})${MANSUBDIR}/${2}${MCOMPRESSSUFFIX}
)
endef

$(call process_pairs,__process_mlink,${MLINKS})

manlinks: manpages

# Html rules
.PHONY: html
html: ${HTMLPAGES}

ifneq (${HTMLPAGES},)

__gen_dest_file = ${DESTDIR}${HTMLDIR}/$(suffix ${1})/$(basename $(notdir ${1})).html

define __gen_install_rule
$(call __gen_dest_file,${I}): ${I}
	${MINSTALL} ${.ALLSRC} ${.TARGET}
endef

$(foreach I,${HTMLPAGES},$(eval $(value __gen_install_rule)))

ifeq ($(call tolower,${MKINSTALL}),yes)
destination_htmls = $(foreach I,${HTMLPAGES},$(call __gen_dest_file,${I}))
endif

installhtml:            ${destination_htmls}
CLEANFILES +=		${HTMLPAGES}

ifeq ($(call tolower,${MKHTML}),yes)
do_install1: installhtml
realdo_all: ${HTMLPAGES}
UNINSTALLFILES +=	${destination_htmls}
INSTALLDIRS    +=	$(dirs ${destination_htmls})
endif # MKHTML
endif # HTMLPAGES

endif # _MKC_IMP_MAN_MK
