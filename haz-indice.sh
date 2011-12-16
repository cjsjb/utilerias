#!/bin/bash

INDICE=extras/indice.fodt
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
		ISPDF=${n#*pdf}

		if [ -z "${ISPDF}" ]; then
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

cat ${INDICE}.head ${INDICE}.body ${INDICE}.tail > ${INDICE}

UNOCONV=$(which unoconv)
if [ ! -z "${UNOCONV}" ]; then
	${UNOCONV} ${INDICE}
else
	echo "Required: unoconv"
	echo "Please convert ${INDICE} to ${INDICE%%.fodt}.pdf somehow"
	exit 1
fi
