.include <_mkc.common.mk>

.if defined(MKC_NOBSDMK) && !empty(MKC_NOBSDMK:M[Yy][Ee][Ss])
.include <own.mk>
.else
.include <bsd.own.mk>
.endif
