# Copyright (c) 2009-2014 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _BSD_FILES_MK
_BSD_FILES_MK := 1

.PHONY: filesinstall
filesinstall: # ensure existence

include mkc.init.mk

do_install1: filesinstall

ifneq (${FILES},)

realdo_all: ${FILES}

ifeq ($(call tolower,${MKINSTALL}),yes)

define gen_destfile
    ${DESTDIR}$(firstword \
    ${FILESDIR_${1}} ${FILESDIR})/$(firstword \
    ${FILESNAME_${1}} ${FILESNAME} $(notdir ${1}))
endef

destination_files = $(foreach F,${FILES},$(call gen_destfile,${F}))

filesinstall: ${destination_files}
.PRECIOUS: ${destination_files}
.PHONY: ${destination_files}

#__fileinstall: .USE
#	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} \
#	    -o ${FILESOWN_${.ALLSRC:T}:U${FILESOWN}:Q} \
#	    -g ${FILESGRP_${.ALLSRC:T}:U${FILESGRP}:Q} \
#	    -m ${FILESMODE_${.ALLSRC:T}:U${FILESMODE}} \

__fileinstall = \
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} \
	    -o $(call gen_install_switch,FILESOWN) \
	    -g $(call gen_install_switch,FILESGRP) \
	    -m $(call gen_install_switch,FILESMODE) \
	    ${.ALLSRC} ${.TARGET}


define gen_install_rule
$(call gen_destfile,${F}): ${F}
	$(__fileinstall)
endef
$(foreach F,$(sort ${FILES}),$(eval $(value gen_install_rule)))

UNINSTALLFILES  +=	${destination_files}
INSTALLDIRS     +=	$(filter-out ./,$(dir ${destination_files}))
endif # MKINSTALL
endif # FILES

endif # _BSD_FILES_MK
