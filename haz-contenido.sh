#!/bin/bash

source libro.inc

if [ ! -z "${EDICION}" ]; then
	WORKBRANCH=${EDICION}
else
	DAY=$(date +"%Y%m%d")
	WORKBRANCH="libro-${DAY}"
fi
WORKOUTPUT="contenido.pdf"
WORKDIR=$(pwd)
INDEX=${WORKDIR}/indice.txt

THREAD=""
declare -a pagealignment
pagealignment[0]="l"
pagealignment[1]="r"


#rm -rf partituras
mkdir -p partituras

LIBRO="\
	${ENTRADA} \
	${KIRIE} \
	${GLORIA} \
	${ALELUYA} \
	${OFERTORIO} \
	${SANTO} \
	${CORDERO} \
	${COMUNION} \
	${SALIDA} \
	"

[ -e ${INDEX} ] && rm ${INDEX}
CUENTA=1
for i in ${LIBRO}; do
	arch="${i}"
	pagealignwant=

	# page-aligned?
	if [ "${i:1:1}" = ":" ]; then
		arch="${i:2}"
		pagealignwant="${i:0:1}"
	fi

	eldir=$(dirname $arch)
	localdir=${eldir#*\/}
	localfile=$(basename $arch)
	filetype=${localfile#*\.}

	if [ "${filetype}" = "ly" -a -e "partituras/${arch}" ]; then
		if [ -d "partituras/${localdir}/.git" ]; then
			pushd "partituras/${localdir}/" >/dev/null
			git checkout m/master
			popd >/dev/null
		else
			echo "Not controlled by GIT? Who are YOU??" && exit 1
		fi

		pushd "partituras/${localdir}" > /dev/null

		haybranch=$(git branch | cut -c3- | grep "^${WORKBRANCH}$")
		if [ -z "${haybranch}" ]; then
			git checkout -b "${WORKBRANCH}" --track m/master
		else
			git checkout "${WORKBRANCH}"
			git rebase m/master
		fi

		currentpagemod=$( echo "${CUENTA} % 2" | bc)
		currentpagealignment=${pagealignment[${currentpagemod}]}
		[ -n "${pagealignwant}" ] && if [ ! "${currentpagealignment}" = "${pagealignwant}" ]; then
			THREAD="${THREAD} extras/hoja-blanca.pdf"
			CUENTA=$(( $CUENTA + 1 ))
		fi

		perl -i -p -e "s#first-page-number = [0-9]*\$#first-page-number = ${CUENTA}#g" ${localfile}

		TITLE=$(grep title ${localfile} | grep -v subtitle | egrep -o \".*\"$ | tr -d \")
		SUBTITLE=$(grep subtitle ${localfile} | grep -v subsubtitle | egrep -o \".*\"$ | tr -d \")
		IENTRY="${TITLE}"; [ -n "${SUBTITLE}" ] && IENTRY="${IENTRY} ${SUBTITLE}"
		echo ${CUENTA},${IENTRY} >> ${INDEX}

		git diff --exit-code ${localfile} ||
			git commit "${localfile}" -m "Paginación de libro para ${WORKBRANCH}."
		lilypond ${localfile}
		rm ${localfile%%.ly}.ps
		pdfpages=$(strings ${localfile%%.ly}.pdf | egrep -o '/Count\ [0-9]*$' | sed -e 's#\/Count\ ##g')
		echo "Pages=[${pdfpages}]"
		THREAD="${THREAD} partituras/${localdir}/${localfile%%.ly}.pdf"

		popd >/dev/null
	elif [ "${filetype}" = "pdf" -a -e "${arch}" ]; then
		currentpagemod=$( echo "${CUENTA} % 2" | bc)
		currentpagealignment=${pagealignment[${currentpagemod}]}
		[ -n "${pagealignwant}" ] && if [ ! "${currentpagealignment}" = "${pagealignwant}" ]; then
			THREAD="${THREAD} extras/hoja-blanca.pdf"
			CUENTA=$(( $CUENTA + 1 ))
		fi

		echo ${CUENTA},${localfile} >> ${INDEX}
		pdfpages=$(strings ${localdir}/${localfile} | egrep -o '/Count\ [0-9]*$' | sed -e 's#\/Count\ ##g')
		echo "Pages=[${pdfpages}]"
		THREAD="${THREAD} ${localdir}/${localfile}"
	fi

	[ -z "${pdfpages}" ] && pdfpages=0
	CUENTA=$(( $CUENTA + ${pdfpages} ))

done

yes quit | gs -sDEVICE=pdfwrite -sOutputFile=${WORKOUTPUT} ${THREAD}
