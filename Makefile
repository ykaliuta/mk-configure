# Copyright (c) 2014 by Aleksey Cheusov
#
# See LICENSE file in the distribution.
############################################################

.DEFAULT_GOAL := all

.DEFAULT:
	@unset ROOT_GROUP; ${MAKE} -I ${CURDIR}/mk -I ${CURDIR}/features -f main.mk ${MAKECMDGOALS}
