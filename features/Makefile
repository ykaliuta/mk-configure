define __setup_feature
$(eval FILES +=	mkc_${f}.h mkc_imp.f_${f}.mk ${f}/${f}.c)
FILESDIR_mkc_imp.f_${f}.mk :=	${MKFILESDIR}
FILESDIR_mkc_${f}.h        :=	${FEATURESDIR}
FILESDIR_${f}/${f}.c       :=	${FEATURESDIR}/${f}
endef
$(foreach f,strlcat strlcpy getline,$(eval $(value __setup_feature)))

define __setup_feature
$(eval FILES +=	mkc_${f}.h mkc_imp.f_${f}.mk)
FILESDIR_mkc_imp.f_${f}.mk :=	${MKFILESDIR}
FILESDIR_mkc_${f}.h        :=	${FEATURESDIR}
endef
$(foreach f,libm libdl SLIST RB,$(eval $(value __setup_feature)))

define __setup_feature
$(eval FILES         +=	${f})
FILESDIR_${f}  :=	${FEATURESDIR}
endef
$(foreach f,netbsd_sys_queue.h netbsd_sys_tree.h,$(eval $(value __setup_feature)))

LINKS += ${MKFILESDIR}/mkc_imp.f_RB.mk ${MKFILESDIR}/mkc_imp.f_SPLAY.mk

LINKS += ${FEATURESDIR}/mkc_RB.h ${FEATURESDIR}/mkc_SPLAY.h

define __setup_feature
LINKS += ${MKFILESDIR}/mkc_imp.f_SLIST.mk ${MKFILESDIR}/mkc_imp.f_${i}.mk
LINKS += ${FEATURESDIR}/mkc_SLIST.h ${FEATURESDIR}/mkc_${i}.h

# the following section is for tests/sys_queue regression test
all: mkc_imp.f_${i}.mk mkc_${i}.h
mkc_imp.f_${i}.mk: mkc_imp.f_SLIST.mk
	cp mkc_imp.f_SLIST.mk ${.TARGET}
mkc_${i}.h: mkc_SLIST.h
	cp mkc_SLIST.h ${.TARGET}
CLEANFILES +=	mkc_${i}.h mkc_imp.f_${i}.mk
endef
$(foreach i,SIMPLEQ STAILQ LIST TAILQ CIRCLEQ,$(eval $(value __setup_feature)))

#
include mkc.files.mk
