# Copyright (c) 2010-1013 by Aleksey Cheusov
# Copyright (c) 1994-2009 The NetBSD Foundation, Inc.

######################################################################
ifndef _MKC_IMP_DEP_MK
ifneq (${_SRCS_ALL},)

_MKC_IMP_DEP_MK := 1

DISTCLEANFILES  +=	.depend ${__DPSRCS.d} ${CLEANDEPEND}

##### Basic targets
.PHONY: do_depend1 do_depend2
realdo_depend: do_depend1 do_depend2
do_depend2: do_depend1
do_depend1: # ensure existence

##### Default values
MKDEP          ?=	mkdep
MKDEP_SUFFIXES ?=	.o .os .op
MKDEP_CC       ?=	${CC}

##### Build rules
# some of the rules involve .h sources, so remove them from mkdep line

define gen_dep_names
$(call replace_extentions,c m s S C cc cpp cxx,d,${1})
endef

__DPSRCS.all  = $(call gen_dep_names,${_SRCS_ALL}) \
		$(call gen_dep_names,${DPSRCS})
__DPSRCS.d    = $(filter %.d,$(sort ${__DPSRCS.all}))
__DPSRCS.notd = $(filter-out %.d,$(sort ${__DPSRCS.all}))

do_depend1: ${DPSRCS}
do_depend2: .depend

MESSAGE.dep ?=	@${_MESSAGE} "DEP: $@"

#.depend: VPATH :=
#${__DPSRCS.d}: VPATH :=

ifneq (${__DPSRCS.d},)
${__DPSRCS.d}: ${__DPSRCS.notd} ${DPSRCS}
endif # __DPSRCS.d

ifeq (${MKDEP_TYPE},nbmkdep)
ddash=--
else
ddash=
endif

define filter_flags
$(filter -I% -D% -U%,$(call sed,s/-([IDU])[  ]*/-\1/g,${1}))
endef

ifeq (${MKDEP_TYPE},makedepend)
MKDEP.c   = ${MAKEDEPEND} -f- ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${CFLAGS}) ${_CPPFLAGS} > $@
MKDEP.m   = ${MKDEP} -f- ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${OBJCFLAGS}) ${_CPPFLAGS} > $@
MKDEP.cc  = ${MKDEP} -f- ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${CXXFLAGS}) ${_CPPFLAGS} > $@
MKDEP.s   = ${MKDEP} -f- ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${AFLAGS}) ${_CPPFLAGS} > $@
else
MKDEP.c   = ${MKDEP} -f $@ ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${CFLAGS}) ${_CPPFLAGS}
MKDEP.m   = ${MKDEP} -f $@ ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${OBJCFLAGS}) ${_CPPFLAGS}
MKDEP.cc  = ${MKDEP} -f $@ ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${CXXFLAGS}) ${_CPPFLAGS}
MKDEP.s   = ${MKDEP} -f $@ ${ddash} ${MKDEPFLAGS} \
	    $(call filter_flags,${AFLAGS}) ${_CPPFLAGS}
endif

.depend: ${__DPSRCS.d}
	${MESSAGE.dep}
	@${RM} -f $@
ifeq (${MKDEP_TYPE},nbmkdep)
	@${MKDEP} -d -f $@ -s $(call shell-quote ${MKDEP_SUFFIXES}) ${__DPSRCS.d}
else
	@sed 's/^\([^ ]*\)[.]o\(.*\)$$/${MKDEP_SUFFIXES:C,^,\\\\1,}\2/' ${__DPSRCS.d} > ${.TARGET}
endif

.SUFFIXES: .d .s .S .c .C .cc .cpp .cxx .m

.c.d:
	${MESSAGE.dep}
	@env CC=$(call shell-quote,${MKDEP_CC}) ${MKDEP.c} $<

.m.d:
	${MESSAGE.dep}
	@${MKDEP.m} $<

.s.d .S.d:
	${MESSAGE.dep}
	@env CC=$(call shell-quote,${MKDEP_CC}) ${MKDEP.s} $<

.C.d .cc.d .cpp.d .cxx.d:
	${MESSAGE.dep}
	@env CC=$(call shell-quote,${MKDEP_CC}) ${MKDEP.cc} $<

endif # defined(SRCS)

######################################################################
endif # _MKC_IMP_DEP_MK
