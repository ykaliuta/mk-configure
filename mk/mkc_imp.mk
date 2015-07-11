# Copyright (c) 2009-2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

include mkc.gmake.mk

include mkc_imp.preinit.mk

ifdef SUBDIR
SUBPRJ = ${SUBDIR}
endif

ifdef SUBPRJS
# for backward compatibility only, use SUBPRJ!
SUBPRJ   +=	${SUBPRJS}
endif # defined(SUBPRJS)

include mkc_imp.lua.mk
include mkc_imp.pod.mk
include mkc.init.mk

ifdef AXCIENT_LIBDEPS # This feature was proposed by axcient.com developers
all_deps != mkc_get_deps $(patsubst ${SUBPRJSRCTOP}/%,%,${CURDIR})
# $(1) -- single dependency
define dep_loop_body
-include ${SUBPRJSRCTOP}/$(1)/linkme.mk
DPLDADD   ?=	$(patsubst lib%,%,$(notdir $(1)))
DPLIBDIRS ?=	${OBJDIR_$(subst /,_,$(1))}
DPINCDIRS ?=	${SRCDIR_$(subst /,_,$(1))} ${OBJDIR_$(subst /,_,$(1))}
include mkc_imp.dpvars.mk
endef
$(foreach p,${all_deps},$(eval $(call dep_loop_body,${p})))
endif

ifdef DPLIBDIRS
$(warning This way of using DPLIBDIRS is deprecated since 2014-08-21)

# $(1) one directory
define dir_loop_body
DPLIBDIRS = $(patsubst ${SUBPRJSRCTOP}/%,%,$(subst /,_,$(1)))
include mkc_imp.dpvars.mk
endef

_DPLIBDIRS := ${DPLIBDIRS}
$(foreach _dir,${_DPLIBDIRS},$(eval $(call dir_loop_body,$(_dir))))

undefine _DPLIBDIRS
undefine DPLIBDIRS
endif

ifdef LIBDEPS
# library dependencies
SUBPRJ          +=	${LIBDEPS}
AXCIENT_LIBDEPS :=	${LIBDEPS}
EXPORT_VARNAMES +=	AXCIENT_LIBDEPS
endif # defined(LIBDEPS)

ifndef LIB
ifndef SUBPRJ
_use_prog :=	1
endif
endif

ifdef FOREIGN
include mkc_imp.foreign_${FOREIGN}.mk
endif
include mkc_imp.rules.mk
include mkc_imp.obj.mk

# Make sure all of the standard targets are defined, even if they do nothing.
.PHONY: do_install1 do_install2
do_install1 do_install2:

.PHONY: cleandir
distclean: cleandir
cleandir:

ifeq ($(call tolower,${MKINSTALLDIRS}),yes)
install: post_install
post_install: do_install
do_install: pre_install
pre_install: post_installdirs
post_installdirs: do_installdirs
do_installdirs: pre_installdirs
endif

realdo_install: do_install2
do_install2: do_install1

# skip uninstalling files and creating destination dirs for mkc.subprj.mk
ifndef SUBPRJ

realdo_uninstall:
	-${UNINSTALL} ${UNINSTALLFILES}

realdo_installdirs:
	for d in _ $(sort $(patsubst %/.,%,${INSTALLDIRS})); do \
		test "$$d" = _ || ${INSTALL} -d -m ${DIRMODE} "$$d"; \
	done

filelist:
	@for d in $(sort ${UNINSTALLFILES}); do \
		echo $$d; \
	done

test:

endif # SUBPRJ

###########
# TODO: quote for shell
define print_cmd
printf "%s=%s\n" $(1) ${$(1)}

endef

.PHONY : print_values
print_values :
	@$(foreach v,${VARS},$(call print_cmd,${v}))

# TODO: quote for shell
define print2_cmd
printf "%s\n" ${$(1)}

endef
.PHONY : print_values2
print_values2 :
	@$(foreach v,${VARS},$(call print2_cmd,${v}))

###########
check_mkc_err_msg:
	@if test -n '${MKC_ERR_MSG}'; then \
	    for msg in '' ${MKC_ERR_MSG}; do \
		fn=`printf '%s\\n' "$$msg" | sed -n 's/^%%%: //p'`; \
		if test -n "$$fn"; then \
		    awk '{print "ERROR: " $$0}' "$$fn"; ex=1; \
		elif test -n "$$msg"; then printf '%s\\n' "$$msg"; ex=1; \
		fi; \
	    done; \
	    exit $$ex; \
	fi

all: post_all
post_all: do_all
do_all: pre_all
pre_all: post_errorcheck
post_errorcheck: do_errorcheck
do_errorcheck: pre_errorcheck

realdo_errorcheck: check_mkc_err_msg

include mkc_imp.checkprogs.mk
include mkc_imp.conf-cleanup.mk

# features
ifdef MKC_FEATURES
include $(patsubst %,mkc_imp.f_%.mk,${MKC_FEATURES})
endif

include mkc_imp.conf-cleanup.mk

ifdef MKC_FEATURES
CFLAGS +=	-I${FEATURESDIR}
endif

ifneq ($(or $(call not,${MKC_ERR_MSG}),\
	$(filter ${CLEAN_TARGETS},${MAKECMDGOALS})),)

ifdef LIB
include mkc_imp.lib.mk
else ifdef _use_prog
include mkc_imp.prog.mk
endif

_do_include :=
ifdef _use_prog
_do_include := T
endif
ifdef LIB
_do_include := T
endif

ifneq ($(_do_include),)
include mkc_imp.man.mk
include mkc_imp.info.mk
include mkc_imp.inc.mk
include mkc_imp.intexts.mk
include mkc_imp.pkg-config.mk
include mkc_imp.dep.mk
include mkc_imp.files.mk
include mkc_imp.scripts.mk
include mkc_imp.links.mk
endif # _use_prog || LIB

########################################
ifdef SUBPRJ
include mkc_imp.subprj.mk
endif # SUBPRJ
########################################

include mkc_imp.arch.mk

endif # MKC_ERR_MSG

include mkc_imp.final.mk
