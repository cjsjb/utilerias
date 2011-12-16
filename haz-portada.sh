#!/bin/bash

PORTADA=extras/portada.fodt
PORTOUT=${PORTADA}.body

source libro.inc

cat ${PORTADA}.head > ${PORTADA}

	echo -n '         <text:p text:style-name="P1"><text:span text:style-name="T1">' >> ${PORTADA}
	echo -n ${EDICION}		>> ${PORTADA}
	echo -n '</text:span></text:p>'	>> ${PORTADA}
	echo				>> ${PORTADA}

cat ${PORTADA}.tail >> ${PORTADA}

UNOCONV=$(which unoconv)
if [ ! -z "${UNOCONV}" ]; then
	${UNOCONV} ${PORTADA}
else
	echo "Required: unoconv"
	echo "Please convert ${PORTADA} to ${PORTADA%%.fodt}.pdf somehow"
	exit 1
fi
