#!/bin/sh

# Tested on Ubuntu 8.04


#-- initialize -----------------------------------------------------------------

# load messages
. "`dirname $0`/messages.sh"

# commands
ERVIZ_CMD="`dirname $0`/erviz.sh"
DOT_CMD=dot

# ERD notation (ie, idef1x)
if [ "${NOTATION}" = "" ]; then NOTATION=ie; fi;

# output file type (dot, png, jpeg, pdf, svg, ...)
if [ "${OUT_TYPE}" = "" ]; then OUT_TYPE=png; fi;

# entity color (white, red, blue, green, yellow, orange)
if [ "${ENTITY_COLOR}" = "" ]; then ENTITY_COLOR=white; fi;

# font
# if the font name is not specified by the invoker, default font is used.

# whether stop before exit or not
if [ "${STOP_BEFORE_NORMAL_EXIT}" = "" ]; then STOP_BEFORE_NORMAL_EXIT=0; fi;
if [ "${STOP_BEFORE_ABNORMAL_EXIT}" = "" ]; then STOP_BEFORE_ABNORMAL_EXIT=0; fi;

# whether show progress or not
if [ "${SHOW_PROGRESS}" = "" ]; then SHOW_PROGRESS=0; fi;

# ------------------------------------------------------------------------------


#-- function -------------------------------------------------------------------
validate_output_file()
{	
	FILE_NAME=$1
	
	# file not found
	if [ ! -e "${FILE_NAME}" ]; then
		return 11
	fi
	
	# file size is zero
	if [ ! -s "${FILE_NAME}" ]; then
		return 12
	fi
	
	return 0
}
#-------------------------------------------------------------------------------


#-- function -------------------------------------------------------------------
delete_empty_output_file()
{	
	FILE_NAME=$1
	
	#  file exists and file size is zero
	if [ -e "${FILE_NAME}" -a ! -s "${FILE_NAME}" ]; then
		rm "${FILE_NAME}"
	fi
	
	return 0
}
#-------------------------------------------------------------------------------


#-- function -------------------------------------------------------------------
convert_file()
{
	IN_FILE="$1"
	IN_TYPE="${IN_FILE##*.}"
	IN_EXT=".${IN_TYPE}"
	
	if [ "${IN_TYPE}" = "txt" ]
	then
		if [ "${OUT_TYPE}" = "dot" ]
		then
			# text to dot
			OUT_FILE="`dirname ${IN_FILE}`/`basename ${IN_FILE} ${IN_EXT}`-${NOTATION}.${OUT_TYPE}"
			"${ERVIZ_CMD}" -f "${FONT_NAME}" -c "${ENTITY_COLOR}" -n "${NOTATION}" < "${IN_FILE}" > "${OUT_FILE}"
		else
			# text to image
			OUT_FILE="`dirname ${IN_FILE}`/`basename ${IN_FILE} ${IN_EXT}`-${NOTATION}.${OUT_TYPE}"
			"${ERVIZ_CMD}" -f "${FONT_NAME}" -c "${ENTITY_COLOR}" -n "${NOTATION}" < "${IN_FILE}" | "${DOT_CMD}" -T${OUT_TYPE} > "${OUT_FILE}"			
		fi
	elif [ "${IN_TYPE}" = "dot" ]
	then
		if [ "${OUT_TYPE}" = "dot" ]
		then
			# dot to dot (append tilde before extension)
			OUT_FILE="`dirname ${IN_FILE}`/`basename ${IN_FILE} ${IN_EXT}`~.${OUT_TYPE}"
			 "${DOT_CMD}" -T${OUT_TYPE} < "${IN_FILE}" > "${OUT_FILE}"
		else
			# dot to image
			OUT_FILE="`dirname ${IN_FILE}`/`basename ${IN_FILE} ${IN_EXT}`.${OUT_TYPE}"
			 "${DOT_CMD}" -T${OUT_TYPE} < "${IN_FILE}" > "${OUT_FILE}"
		fi
	else
		echo 1>&2
		echo ${MSG_ERROR}: ${MSG_INVALID_IN_FILE_TYPE}  file=["${IN_FILE}"]  type=["${IN_TYPE}"] 1>&2
		return 1
	fi
	
	CONV_ERR=$?
	if [ ${CONV_ERR} -eq 0 ]; then
		validate_output_file "${OUT_FILE}"
		CONV_ERR=$?
	fi
	
	if [ ${CONV_ERR} -gt 0 ]; then
		delete_empty_output_file "${OUT_FILE}"
		
		echo 1>&2
		echo ${MSG_ERROR}: ${MSG_CONV_FAULT}  file=["${IN_FILE}"] 1>&2
		return 1
	fi
	
	return 0
}
#-------------------------------------------------------------------------------


#-- main -----------------------------------------------------------------------

for IN_FILE in $@
do
	if [ ${SHOW_PROGRESS} = 1 ]
	then
		echo ${MSG_INPUT_FILE} : [${IN_FILE}] 1>&2
	fi
	
	convert_file "${IN_FILE}"
	if [ $? -gt 0 ]; then
		if [ ${STOP_BEFORE_ABNORMAL_EXIT} = 1 ]
		then
			echo 1>&2
			echo ${MSG_PRESS_ANY_KEY_TO_EXIT} 1>&2
			read x #pause
		fi
		exit 1
	fi
done

if [ ${STOP_BEFORE_NORMAL_EXIT} = 1 ]
then
	echo 1>&2
	echo ${MSG_PRESS_ANY_KEY_TO_EXIT} 1>&2
	read x #pause
fi

exit 0

#-------------------------------------------------------------------------------
