CLEANDIRS +=		${.CURDIR}/testdir

.PHONY : test_output
test_output:
	@set -e; \
	\
	echo =========== all ============; \
	${MAKE} showme 2>&1 | \
	sed -e 's,^.*warning:,warning:,' -e 's,little,big,'; \
	${MAKE} distclean > /dev/null

include mkc.minitest.mk
