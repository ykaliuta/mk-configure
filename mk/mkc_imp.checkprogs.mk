define prog_id_var
MKC_PROG.id.$(subst +,x,$(firstword ${1}))
endef

ifneq (${YACC},)
ifneq ($(filter %.y,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${YACC})
$(call prog_id_var,${YACC}) = 	yacc
endif
endif

ifneq (${LEX},)
ifneq ($(filter %..l,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${LEX})
$(call prog_id_var,${LEX}) = 	lex
endif
endif

ifneq (${CC},)
ifneq ($(or $(filter %.c,${_srcsall}),$(filter %.l,${_srcsall}),$(filter %.y,${_srcsall})),)
MKC_REQUIRE_PROGS  +=		$(firstword ${CC})
$(call prog_id_var,${CC}) =	cc
endif
endif

ifneq (${CXX},)
ifneq ($(or $(filter %.cc,${_srcsall}),$(filter %.C,${_srcsall}),$(filter %.cxx,${_srcsall}),$(filter %.cpp,${_srcsall})),)
MKC_REQUIRE_PROGS  +=		$(firstword ${CXX})
$(call prog_id_var,${CXX}) = 	cxx
endif
endif

ifneq (${FC},)
ifneq ($(filter %.f,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${FC})
$(call prog_id_var,${FC}) = 	fc
endif
endif

ifneq (${PC},)
ifneq ($(filter %.p,${_srcsall}),)
MKC_REQUIRE_PROGS  +=		$(firstword ${PC})
$(call prog_id_var,${PC}) = 	pc
endif
endif
