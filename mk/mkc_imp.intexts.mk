# Copyright (c) 2009-2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

# Given a list of files in INFILES or INSCRIPTS mkc.intexts.mk
# generates them from appropriate *.in files replacing @prefix@,
# @sysconfdir@, @libdir@, @bindir@, @sbindir@, @datadir@ etc. with
# real ${PREFIX}, ${SYSCONFDIR} etc. See examples/ projects.

ifndef _MKC_IMP_INTEXTS_MK
_MKC_IMP_INTEXTS_MK := 1

MESSAGE.gen ?=	@${_MESSAGE} "GEN: ${.TARGET}"

INTEXTS_SED  +=	-e 's,@sysconfdir@,${SYSCONFDIR},g'
INTEXTS_SED  +=	-e 's,@libdir@,${LIBDIR},g'
INTEXTS_SED  +=	-e 's,@libexecdir@,${LIBEXECDIR},g'
INTEXTS_SED  +=	-e 's,@prefix@,${PREFIX},g'
INTEXTS_SED  +=	-e 's,@bindir@,${BINDIR},g'
INTEXTS_SED  +=	-e 's,@sbindir@,${SBINDIR},g'
INTEXTS_SED  +=	-e 's,@datadir@,${DATADIR},g'
INTEXTS_SED  +=	-e 's,@mandir@,${MANDIR},g'
INTEXTS_SED  +=	-e 's,@incsdir@,${INCSDIR},g'
INTEXTS_SED  +=	-e 's,@vardir@,${VARDIR},g'
INTEXTS_SED  +=	-e 's,@sharedstatedir@,${SHAREDSTATEDIR},g'

define __first
INTEXTS_SED += -e 's$(COMMA)@$(firstword $1)$(call __second,$(wordlist 2,$(words $1),$1))
endef

define __second
@,$(firstword $1)$(COMMA)g'$(call __start,$(wordlist 2,$(words $1),$1))
endef

define __start
$(if $1,$(eval $(call __first,$1)),)
endef


ifeq ($(filter clean cleandir distclean,${MAKECMDGOALS}),)
ifneq ($(shell echo $(words ${INTEXTS_REPLS}) | grep '.*[13579]$$'),)
MKC_ERR_MSG +=	"ERROR: odd number of tokens in INTEXTS_REPLS"
else
$(call __start,${INTEXTS_REPLS})
endif
endif

#TODO
#.NOPATH: ${i:T}
$(notdir ${INFILES}): %: %.in
	${MESSAGE.gen}
	${_V} sed ${INTEXTS_SED} ${.ALLSRC} > ${.TARGET} && \
	chmod 0644 ${.TARGET}

#TODO
#.NOPATH: ${i:T}
$(notdir ${INSCRIPTS}): %: %.in
	${MESSAGE.gen}
	${_V} sed ${INTEXTS_SED} ${.ALLSRC} > ${.TARGET} && \
	chmod 0755 ${.TARGET}

CLEANFILES   +=	$(notdir ${INSCRIPTS}) $(notdir ${INFILES})

realdo_all: $(notdir ${INSCRIPTS}) $(notdir ${INFILES})

######################################################################
endif # _MKC_IMP_INTEXTS_MK
