#!/bin/bash
BUILD_DIR=`dirname $0`

EASYBASHGUI_VERSION=1.3.1
source ${BUILD_DIR}/../tools/EasyBashGUI_${EASYBASHGUI_VERSION}/easybashgui_${EASYBASHGUI_VERSION}

clear
echo "What are you going to do?"
echo "1 - upload all available RPMs"
echo "2 - upload selected RPMs"
echo ""
read UPLOAD

RELEASE_DIR=`cat build.properties | egrep -v "^#" | grep release.files.rootdir | awk -F"=" '{print $2;}' | sed '{s#\r##;}'`

case $UPLOAD in
1)
	clear
	echo ""
	echo "Please enter password and press Return to continue or Ctrl-C to cancel!"
	stty_orig=`stty -g`
	stty -echo
	read SECRET
	stty $stty_orig

	for rpm in `find ${RELEASE_DIR} -name *.rpm`;do
		echo "uploading $rpm now on SOE RH 5 repo..."
		rhnpush --server si0bos32 --force -u jboss-soe-upload -p ${SECRET} -c bosch-ciafw1-soe ${rpm}
		echo "uploading $rpm now on SOE RH 6 repo..."
		rhnpush --server si0bos32 --force -u jboss-soe-upload -p ${SECRET} -c bosch-ciafw1-soe-rh6 ${rpm}
	done
	echo "uploading done."
	;;
2)
	pushd ${RELEASE_DIR}
	FILTER=${1:-\*}
	echo ""
	echo -e "Please enter a filter criteria and press Return to continue or Ctrl-C to cancel! [${FILTER}]"
	read FILTER_TEMP
	if [ -n $FILTER_TEMP ]; then
		FILTER=$FILTER_TEMP
	fi

	for rpm in `find . -type f -name \*${FILTER}\*.rpm`;do
		rpmmenu="$rpmmenu `basename $rpm`"
	done
	list $rpmmenu
	popd
	choice="$(0< "${dir_tmp}/${file_tmp}" )"
	
	if_arg_is_an_empty_variable_then_exit "choice" #bye, bye, user... :)
	
	clear
	echo "This will be uploaded to satellite:"
	echo "$choice"
	echo ""
	echo "Please enter password and press Return to continue or Ctrl-C to cancel!"
	
	stty_orig=`stty -g`
	stty -echo
	read SECRET
	stty $stty_orig
	
	for rpm in ${choice}; do
		echo "uploading $rpm now on SOE RH 5 repo..."
		rhnpush --server si0bos32 --force -u jboss-soe-upload -p ${SECRET} -c bosch-ciafw1-soe `find ${RELEASE_DIR} -name ${rpm}`
		echo "uploading $rpm now on SOE RH 6 repo..."
		rhnpush --server si0bos32 --force -u jboss-soe-upload -p ${SECRET} -c bosch-ciafw1-soe-rh6 `find ${RELEASE_DIR} -name ${rpm}`
	done
	echo "uploading done."
	;;
*)	echo "Wrong selection"
	;;
esac


####
clean_temp

