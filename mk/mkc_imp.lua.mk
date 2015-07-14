# Copyright (c) 2010 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################


#LUA_SRC.<mod> = <lmod>
$(foreach i,${LUA_LMODULES},$(eval \
LUA_MODULES += $(basename $(notdir ${i})) \
LUA_SRCS.$(basename $(notdir ${i})) = ${i}))

ifneq ($(or ${LUA_MODULES},${LUA_CMODULE}),)

#### .lua modules
ifdef LUA_MODULES
ifndef LUA_LMODDIR
PKG_CONFIG_DEPS     +=	lua
PKG_CONFIG_VARS.lua +=	INSTALL_LMOD
LUA_LMODDIR         ?=	${PKG_CONFIG.var.lua.INSTALL_LMOD}
endif #LUA_LMODDIR

# $(1) lua module
define gen_modules
LUA_SRCS.$(1)       ?=	$(subst .,_,$(1)).lua
FILES               +=	$${LUA_SRCS.$(1)}
FILESDIR_$${LUA_SRCS.$(1)} =	${LUA_LMODDIR}/$(patsubst %/,%,$(dir $(subst .,/,$(1))))
FILESNAME_$${LUA_SRCS.$(1)} =	$(notdir $(subst .,/,$(1))).lua
endef
$(eval $(foreach i,${LUA_MODULES},$(call gen_modules,${i})))
endif # defined(LUA_MODULES)

### .c module
ifdef LUA_CMODULE
PKG_CONFIG_DEPS     +=	lua

ifndef LUA_CMODDIR
PKG_CONFIG_VARS.lua +=	INSTALL_CMOD
LUA_CMODDIR         ?=	${PKG_CONFIG.var.lua.INSTALL_CMOD}
endif
LIB        =		$(notdir $(shell echo ${LUA_CMODULE} | sed "s|.|/|"))
SRCS      ?=		$(subst .,_,${LUA_CMODULE}.c)
MKDLL      =		Only
DLL_EXT    =		.so
LIBDIR     =		${LUA_CMODDIR}/$(dir $(subst .,/,${LUA_CMODULE}))
endif # defined(LUA_CMODULES)

######################
include mkc_imp.pkg-config.mk

ifeq (${LUA_LMODDIR},)
MKC_ERR_MSG  +=	"ERROR: pkg-config --variable=INSTALL_LMOD lua failed"
endif

ifeq (${LUA_CMODDIR},)
MKC_ERR_MSG  +=	"ERROR: pkg-config --variable=INSTALL_CMOD lua failed"
ifeq (${MKC_ERR_MSG},)
MKC_REQUIRE_HEADERS +=	lua.h
endif # !empty(MKC_ERR_MSG)
endif # LUA_CMODULE

endif # LUA_MODULES) || LUA_CMODULE # _check for gmake
