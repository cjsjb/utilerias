#!/bin/bash

UTILDIR=$(readlink -f $(dirname $0))

if [ -z "${EDICION}" ]; then
	DAY=$(date +"%Y%m%d")
	EDICION="libro-${DAY}"
fi
PORTADA="${UTILDIR}/extras/portada.fodt"
PORTOUT=portada.fodt

cat ${PORTADA}.head > ${PORTOUT}

	echo -n '         <text:p text:style-name="P1"><text:span text:style-name="T1">' >> ${PORTOUT}
	echo -n ${EDICION}		>> ${PORTOUT}
	echo -n '</text:span></text:p>'	>> ${PORTOUT}
	echo				>> ${PORTOUT}

cat ${PORTADA}.tail >> ${PORTOUT}

UNOCONV=$(which unoconv)
if [ ! -z "${UNOCONV}" ]; then
	${UNOCONV} ${PORTOUT}
else
	echo "Required: unoconv"
	echo "Please convert ${PORTOUT} to ${PORTADA%%.fodt}.pdf somehow"
	exit 1
fi
