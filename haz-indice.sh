#!/bin/bash

UTILDIR=$(readlink -f $(dirname $0))

INDICE="indice.fodt"
INDOUT=${INDICE}.body

cat << EOF > ${INDOUT}
   <office:body>
      <office:text>
         <text:p text:style-name="P9"/>
         <text:p text:style-name="P9">ÍNDICE</text:p>
         <text:p text:style-name="P5"/>
EOF

cat indice.txt |
	while read n; do
		PAGE=${n%%,*}
		TITLE=${n#*,}
		# wait, what?
		ISPDF=$(echo $n | cut -d, -f2 | egrep -o '.pdf$')

		if [ "${ISPDF}" ]; then
			TITLE=$(echo $n | cut -d, -f3)
			echo -n '         <text:p text:style-name="ParrSeccion">'	>> ${INDOUT}
			echo -n ${TITLE}	>> ${INDOUT}
			echo -n '<text:tab/>'	>> ${INDOUT}
			echo -n ${PAGE}		>> ${INDOUT}
			echo -n '</text:p>'	>> ${INDOUT}
			echo >> ${INDOUT}
		else
			echo -n '         <text:p text:style-name="ParrCanto"><text:tab/>'	>> ${INDOUT}
			echo -n ${TITLE}	>> ${INDOUT}
			echo -n '<text:tab/>'	>> ${INDOUT}
			echo -n ${PAGE}		>> ${INDOUT}
			echo -n '</text:p>'	>> ${INDOUT}
			echo >> ${INDOUT}
		fi
	done

cat << EOF >> ${INDOUT}
      </office:text>
   </office:body>
EOF

cat ${UTILDIR}/extras/${INDICE}.head ${INDOUT} ${UTILDIR}/extras/${INDICE}.tail > ${INDICE}
rm ${INDOUT}

LOBIN=$(which libreoffice)
if [ ! -z "${LOBIN}" ]; then
	libreoffice --convert-to pdf:writer_pdf_Export --outdir $(pwd)/ ${INDICE}
else
	echo "Required: libreoffice"
	echo "Please convert ${INDICE} to ${INDICE%%.fodt}.pdf somehow"
	exit 1
fi
