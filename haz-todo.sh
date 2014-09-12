#!/bin/bash

BRANCH=master
[ -n "${1}" ] && BRANCH="${1}"

REPO=$(which repo || :)
if [ -z "${REPO}" ]; then
	if [ ! -s ./repo ]; then
		curl -k https://storage.googleapis.com/git-repo-downloads/repo -O ./repo
		chmod a+x ./repo
	fi
	REPO=$(readlink -f ./repo)
fi

${REPO} init -u git://gitorious.org/cjsjb-partituras/manifiesto.git -b ${BRANCH}
${REPO} sync

# Definir contenido del libro:
php manifest2libro.php .repo/manifest.xml > libro.inc
# Generar el contenido:
./haz-contenido.sh
# Generar la portada:
./haz-portada.sh
# Generar el índice:
./haz-indice.sh

yes quit | gs -sDEVICE=pdfwrite -sOutputFile=cjsjb-partituras.pdf \
      extras/portada.pdf \
      extras/hoja-blanca.pdf \
      extras/indice.pdf \
      extras/hoja-blanca.pdf \
      contenido.pdf

echo
