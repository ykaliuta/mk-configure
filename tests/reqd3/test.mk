test:
	@echo 'Testing ${.CURDIR}... ' 1>&2; \
	set -e; cd ${.CURDIR}; \
	tmp_out=${.OBJDIR}/${.CURDIR:T}.test.out; \
	rm -f $$tmp_out; \
	${MAKE} all 2>&1 | head -1 > $$tmp_out; \
	diff ${.CURDIR}/expect.out $$tmp_out && \
	echo '      succeeded' 1>&2 || \
	{ echo '      FAILED' 1>&2; false; }
