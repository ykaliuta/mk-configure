# Copyright (c) 2009-2014 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.
# Copyright (c) 1988, 1989, 1993 The Regents of the University of California
# Copyright (c) 1988, 1989 by Adam de Boor
# Copyright (c) 1989 by Berkeley Softworks
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_SCRIPTS_MK
_MKC_IMP_SCRIPTS_MK := 1

scriptsinstall:	# ensure existence
.PHONY: scriptsinstall
do_install1:	scriptsinstall

realdo_all: ${SCRIPTS}

ifdef SCRIPTS
ifeq ($(call tolower,${MKINSTALL}),yes)

define __gen_dest_script
	${DESTDIR}$(or ${SCRIPTSDIR_$(subst /,_,${1})},\
			${SCRIPTSDIR})/$(or ${SCRIPTSNAME_$(subst /,_,${1})},\
					${SCRIPTSNAME}, \
					$(notdir ${1}))
endef

destination_scripts := $(foreach I,${SCRIPTS},$(call __gen_dest_script,${I}))
UNINSTALLFILES +=	${destination_scripts}
INSTALLDIRS    +=	$(filter-out ./,$(dir ${destination_scripts}))
endif # MKINSTALL

scriptsinstall:  ${destination_scripts}
.PRECIOUS:       ${destination_scripts}
.PHONY:          ${destination_scripts}

__scriptinstall = \
	${INSTALL} ${RENAME} ${PRESERVE} ${COPY} \
	    -o $(call gen_install_switch,SCRIPTSOWN) \
	    -g $(call gen_install_switch,SCRIPTSGRP) \
	    -m $(call gen_install_switch,SCRIPTSMODE) \
	    ${.ALLSRC} ${.TARGET}

define __gen_install_rule
$(call __gen_dest_script,${F}): ${F}
	$(__scriptinstall)
endef

$(foreach F,$(sort ${SCRIPTS}),$(eval $(value __gen_install_rule)))

endif # defined(SCRIPTS)

endif # _MKC_IMP_SCRIPTS_MK
