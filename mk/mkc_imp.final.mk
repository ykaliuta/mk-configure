# Copyright (c) 2009-2012 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

ifndef MKC_IMP.FINAL.MK
MKC_IMP.FINAL.MK = 1

VPATH += ${SRC_PATHADD}

LDADD +=	${DPLIBS} # DPLIBS is deprecated (2012-08-13)
LDADD +=	${LDADD_${PROJECTNAME}}

LDFLAGS +=	${LDFLAGS_${PROJECTNAME}}

ifneq ($(filter %.l,${SRCS}),)
LDADD +=	${LEXLIB}
endif

$(foreach i,$(filter-out ${NOEXPORT_VARNAMES},${EXPORT_VARNAMES}),$(eval \
export_cmd += ${i}=$(call shell-quote,${${i}}); export ${i}; \
))

ifeq (${MKRELOBJDIR},yes)
ifdef SRCTOP
export_cmd  +=	MAKEOBJDIR=${.OBJDIR}/$(call sed,s/^.*-//g,$@); \
	export MAKEOBJDIR; ${MKDIR} -p $${MAKEOBJDIR};
endif
endif

##########
realdo_clean: mkc_clean
.PHONY: mkc_clean
mkc_clean:
ifneq (${CLEANFILES},)
	-${CLEANFILES_CMD} ${CLEANFILES}
endif
ifneq (${CLEANDIRS},)
	-${CLEANDIRS_CMD} ${CLEANDIRS}
endif

#####
distclean: cleandir

realdo_cleandir: mkc_cleandir

mkc_cleandir:
ifneq ($(firstword ${DISTCLEANFILES} ${CLEANFILES}),)
	-${CLEANFILES_CMD} ${DISTCLEANFILES} ${CLEANFILES}
endif
ifneq ($(firstword ${DISTCLEANDIRS} ${CLEANDIRS}),)
	-${CLEANDIRS_CMD} ${DISTCLEANDIRS} ${CLEANDIRS}
endif

##########
# pre_, do_, post_ targets

define __gen_pre_do_post
.PHONY: pre_${t} do_${t} realdo_${t} post_${t}
post_${t}: do_${t}
do_${t}: pre_${t}
${t}: post_${t}
pre_${t}: #ensure existence

do_${t}: realdo_${t}
endef

$(foreach t,${ALLTARGETS},$(eval $(value __gen_pre_do_post)))

# TODO
#${t}: pre_${t} .WAIT do_${t} .WAIT post_${t}
#.if !commands(do_${t})
#do_${t}: realdo_${t}
#.endif

.PHONY: ${TARGETS}

##########

endif # MKC_IMP.FINAL.MK
