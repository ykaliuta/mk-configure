# Copyright (c) 2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

define gen_pic
$(if $(and $(or $(call seq,yes,$(call tolower,${MKPIE})),$(call is_defined,SHLIB_MAJOR)),$(filter lib${1},${STATICLIBS})),_pic,)
endef

$(foreach i,${DPLDADD},$(eval \
LDADD0 += -l${i}$(call gen_pic,${i}) \
))

ifeq (${TARGET_OPSYS},HP-UX)
LDFLAGS0  +=	${CFLAGS.cctold}+b ${CFLAGS.cctold}${LIBDIR}
else
$(eval LDFLAGS0  += ${DPLIBDIRS})
endif

$(eval CPPFLAGS0 += $(addprefix -I,$(sort ${DPINCDIRS})))

undefine DPLIBDIRS
undefine DPINCDIRS
undefine DPLDADD
