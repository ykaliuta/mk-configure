.include <_mkc.common.mk>

.if defined(MKC_NOBSDMK) && !empty(MKC_NOBSDMK:M[Yy][Ee][Ss])
.include <prog.mk>
.else
.include <bsd.prog.mk>
.endif
