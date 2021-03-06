.if !empty(_srcsall:U:M*.y) && !empty(YACC)
MKC_REQUIRE_PROGS  +=			${YACC:[1]}
MKC_PROG.id.${YACC:[1]:S/+/x/g}  =	yacc
.endif

.if !empty(_srcsall:U:M*.l) && !empty(LEX)
MKC_REQUIRE_PROGS  +=			${LEX:[1]}
MKC_PROG.id.${LEX:[1]:S/+/x/g}   =	lex
.endif

.if !empty(_srcsall:U:M*.c) || !empty(_srcsall:U:M*.l) || !empty(_srcsall:U:M*.y) && !empty(CC)
MKC_REQUIRE_PROGS  +=			${CC:[1]}
MKC_PROG.id.${CC:[1]:S|+|x|g}    =	cc
.endif

.if !empty(_srcsall:U:M*.cc) || !empty(_srcsall:U:M*.C) || !empty(_srcsall:U:M*.cxx) || !empty(_srcsall:U:M*.cpp) && !empty(CXX)
MKC_REQUIRE_PROGS  +=			${CXX:[1]}
MKC_PROG.id.${CXX:[1]:S/+/x/g}   =	cxx
.endif

.if !empty(_srcsall:U:M*.f) && !empty(FC)
MKC_REQUIRE_PROGS  +=			${FC:[1]}
MKC_PROG.id.${FC:[1]:S/+/x/g}    =	fc
.endif

.if !empty(_srcsall:U:M*.p) && !empty(PC)
MKC_REQUIRE_PROGS  +=			${PC:[1]}
MKC_PROG.id.${PC:[1]:S/+/x/g}    =	pc
.endif
