define prog_id_var
MKC_PROG.id.$(subst +,x,$(firstword ${1}))
endef

ifneq (${YACC},)
ifneq ($(call filter-glob,*.y,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${YACC})
$(call prog_id_var ${YACC}) = 	yacc
endif
endif

ifneq (${LEX},)
ifneq ($(call filter-glob,*.l,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${LEX})
$(call prog_id_var,${LEX}) = 	lex
endif
endif

ifneq (${CC},)
ifneq ($(or $(call filter-glob,*.c,${_srcsall})$(call filter-glob,*.l,${_srcsall})$(call filter-glob,*.y,${_srcsall})),)
MKC_REQUIRE_PROGS  +=		$(firstword ${CC})
$(call prog_id_var,${CC}) =	cc
endif
endif

ifneq (${CXX},)
ifneq ($(or $(call filter-glob,*.cc,${_srcsall})$(call filter-glob,*.C,${_srcsall})$(call filter-glob,*.cxx,${_srcsall})),)
MKC_REQUIRE_PROGS  +=		$(firstword ${CXX})
$(call prog_id_var,${CXX}) = 	cxx
endif
endif

ifneq (${FC},)
ifneq ($(call filter-glob,*.f,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${FC})
$(call prog_id_var,${FC}) = 	fc
endif
endif

ifneq (${PC},)
ifneq ($(call filter-glob,*.p,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${PC})
$(call prog_id_var,${PC}) = 	pc
endif
endif
