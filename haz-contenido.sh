#!/bin/bash

# libro.def should include one file per line, such as:
#   file1.ly
#   l:file2.ly
#   file3.pdf
#   r:file4.ly

WORKOUTPUT="contenido.pdf"
WORKDIR=$(pwd)
INDEX=${WORKDIR}/indice.txt
UTILDIR=$(readlink -f $(dirname $0))

THREAD=""
declare -a pagealignment
pagealignment[0]="l"
pagealignment[1]="r"


[ -e ${INDEX} ] && rm ${INDEX}
CUENTA=1
while read -r i; do
	[ -z "$i" ] && continue
	arch="${i}"
	pagealignwant=

	# page-aligned?
	if [ "${i:1:1}" = ":" ]; then
		arch="${i:2}"
		pagealignwant="${i:0:1}"
	fi
	descr="$(echo $arch | cut -d: -f2)"
	arch="$(echo $arch | cut -d: -f1)"

	eldir=$(dirname $arch)
	localdir=${eldir#*\/}
	localfile=$(basename $arch)
	filetype=${localfile#*\.}

	if [ "${filetype}" = "ly" -a -e "partituras/${arch}" ]; then
		pushd "partituras/${localdir}" > /dev/null

		currentpagemod=$( echo "${CUENTA} % 2" | bc)
		currentpagealignment=${pagealignment[${currentpagemod}]}
		[ -n "${pagealignwant}" ] && if [ ! "${currentpagealignment}" = "${pagealignwant}" ]; then
			THREAD="${THREAD} ${UTILDIR}/paginas/hoja-blanca.pdf"
			CUENTA=$(( $CUENTA + 1 ))
		fi

		sed -i -e "s#first-page-number = [0-9]*\$#first-page-number = ${CUENTA}#g" ${localfile}

		TITLE=$(grep title ${localfile} | grep -v subtitle | egrep -o \".*\"$ | tr -d \")
		SUBTITLE=$(grep subtitle ${localfile} | grep -v subsubtitle | egrep -o \".*\"$ | tr -d \")
		IENTRY="${TITLE}"
		[ -n "${SUBTITLE}" ] && IENTRY="${IENTRY} ${SUBTITLE}"
		echo ${CUENTA},${IENTRY} >> ${INDEX}

		[ -x ${WORKDIR}/postprocessor.sh ] && bash ${WORKDIR}/postprocessor.sh $(readlink -f ${localfile})

		echo -n "${localfile}... "
		lilypond -s ${localfile}
		rm -f ${localfile%%.ly}.ps
		pdfpages=$(strings ${localfile%%.ly}.pdf | egrep -o '/Count\ [0-9]*$' | sed -e 's#\/Count\ ##g')
		echo "${pdfpages} page(s)"
		THREAD="${THREAD} partituras/${localdir}/${localfile%%.ly}.pdf"

		popd >/dev/null
	elif [ "${filetype}" = "pdf" -a -e "${arch}" ]; then
		echo -n "${descr}... "
		currentpagemod=$( echo "${CUENTA} % 2" | bc)
		currentpagealignment=${pagealignment[${currentpagemod}]}
		[ -n "${pagealignwant}" ] && if [ ! "${currentpagealignment}" = "${pagealignwant}" ]; then
			THREAD="${THREAD} ${UTILDIR}/paginas/hoja-blanca.pdf"
			CUENTA=$(( $CUENTA + 1 ))
		fi

		echo ${CUENTA},${localfile},${descr} >> ${INDEX}
		pdfpages=$(strings ${UTILDIR}/${localdir}/${localfile} | egrep -o '/Count\ [0-9]*$' | sed -e 's#\/Count\ ##g')
		echo "${pdfpages} page(s)"
		THREAD="${THREAD} ${UTILDIR}/${localdir}/${localfile}"
	fi

	[ -z "${pdfpages}" ] && pdfpages=0
	CUENTA=$(( $CUENTA + ${pdfpages} ))

done < libro.def

gs -q -sDEVICE=pdfwrite -dBATCH -dNOPAUSE -sOutputFile=${WORKOUTPUT} ${THREAD}
