# Copyright (c) 2009-2013 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef _MKC_IMP_LINKS_MK
_MKC_IMP_LINKS_MK := 1

.PHONY: linksinstall
linksinstall: # ensure existence

do_install2:	linksinstall

ifeq ($(call tolower,${MKINSTALL}),yes)

__ln_func = ${RM} -f ${DESTDIR}${2}; ${LN} ${DESTDIR}${1} ${DESTDIR}${2};
__ln_s_func = ${RM} -f ${DESTDIR}${2}; ${LN_S} ${1} ${DESTDIR}${2}

linksinstall:
	$(call process_pairs,__ln_func,${LINKS})
	$(call process_pairs,__ln_s_func,${SYMLINKS})


define __add_files_and_dirs1
$(eval UNINSTALLFILES += ${DESTDIR}${2})
$(eval INSTALLDIRS += $(dir ${DESTDIR}${2}))
endef

$(eval $(call process_pairs,__add_files_and_dirs,${LINKS} ${SYMLINKS}))

endif # MKINSTALL=yes
endif # _MKC_IMP_LINKS_MK
