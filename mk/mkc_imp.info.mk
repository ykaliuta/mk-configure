# Copyright (c) 2009-2010 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_INFO_MK
ifdef TEXINFO
_MKC_IMP_INFO_MK := 1

.PHONY: infoinstall

include mkc.init.mk

MAKEINFO     ?=	makeinfo
INFOFLAGS    ?=	
INSTALL_INFO ?=	install-info

.SUFFIXES: .txi .texi .texinfo .info

MESSAGE.texinfo ?=	@${_MESSAGE} "TEXINFO: ${.TARGET}"

.txi.info .texi.info .texinfo.info:
	${MESSAGE.texinfo}
	${_V}${MAKEINFO} ${INFOFLAGS} --no-split -o $@ $<

ifneq (${TEXINFO},)

realdo_all: ${TEXINFO}

define gen_info_names
$(call replace_extentions,texinfo texi txi,info,${1})
endef

INFOFILES = $(call gen_info_names,${TEXINFO})
#${TEXINFO:S/.texinfo/.info/g:S/.texi/.info/g:S/.txi/.info/g}

# TODO
#.NOPATH:	${INFOFILES}

ifneq ($(call tolower,${MKINFO}),no)
realdo_all: ${INFOFILES}

CLEANFILES +=	${INFOFILES}

define gen_destinfo
    ${DESTDIR}$(firstword \
    ${INFODIR_${1}} ${INFODIR})/$(firstword \
    ${INFONAME_${1}} ${INFONAME} $(notdir ${1}))
endef

destination_infos := $(foreach F,${INFOFILES},$(call gen_destinfo,${F}))

infoinstall: ${destination_infos}
.PRECIOUS: ${destination_infos}
.PHONY: ${destination_infos}

define __infoinstall
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} ${INSTPRIV} \
	    -o $(call gen_install_switch,INFOOWN) \
	    -g $(call gen_install_switch,INFOGRP) \
	    -m $(call gen_install_switch,INFOMODE) \
	    ${.ALLSRC} ${.TARGET}
	@${INSTALL_INFO} --remove --info-dir=${DESTDIR}${INFODIR} ${.TARGET}
	${INSTALL_INFO} --info-dir=${DESTDIR}${INFODIR} ${.TARGET}
endef

ifeq ($(call tolower,${MKINSTALL}),yes)
do_install1: infoinstall

define gen_install_rule
$(call gen_destinfo,${F}): ${F}
	${__infoinstall}
endef
$(foreach F,$(sort ${INFOFILES}),$(eval $(value gen_install_rule)))

UNINSTALLFILES  +=	${destination_infos}
INSTALLDIRS     +=	$(filter-out ./,$(dir ${destination_infos}))
endif # MKINSTALL
endif # MKINFO

endif # TEXINFO

endif # _MKC_IMP_INFO_MK
endif
