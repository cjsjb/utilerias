#!/bin/bash

BASEDIR=$(dirname $0)

DOSYNC=1

[ "$1" = "--no-sync" ] && DOSYNC=0

BRANCH=master
[ -n "${1}" ] && BRANCH="${1}"

REPO=$(which repo || :)
if [ -z "${REPO}" ]; then
	if [ ! -s "${BASEDIR}/repo" ]; then
		curl -k https://storage.googleapis.com/git-repo-downloads/repo -O "${BASEDIR}/repo"
		chmod a+x "${BASEDIR}/repo"
	fi
	REPO=$(readlink -f "${BASEDIR}/repo")
fi

if [ ${DOSYNC} -eq 1 ]; then
	${REPO} init -u git://gitorious.org/cjsjb-partituras/manifiesto.git -b ${BRANCH}
	${REPO} sync
fi

# Definir contenido del libro:
php "${BASEDIR}/manifest2libro.php" .repo/manifest.xml > libro.inc
# Generar el contenido:
"${BASEDIR}/haz-contenido.sh"
# Generar la portada:
"${BASEDIR}/haz-portada.sh"
# Generar el índice:
"${BASEDIR}/haz-indice.sh"

yes quit | gs -sDEVICE=pdfwrite -sOutputFile=cjsjb-partituras.pdf \
      "${BASEDIR}/extras/portada.pdf" \
      "${BASEDIR}/extras/hoja-blanca.pdf" \
      "${BASEDIR}/extras/indice.pdf" \
      "${BASEDIR}/extras/hoja-blanca.pdf" \
      contenido.pdf

echo
