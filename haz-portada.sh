#!/bin/bash

# libro.inc should define:
#  EDICION, such as "libro-201209"
#  CONTENIDO, such as "file1.ly l:file2.ly file3.pdf r:file4.ly"
source libro.inc

BASEDIR=$(dirname $0)

if [ -z "${EDICION}" ]; then
	DAY=$(date +"%Y%m%d")
	EDICION="libro-${DAY}"
fi
PORTADA="${BASEDIR}/extras/portada.fodt"
PORTOUT=${PORTADA}.body

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
