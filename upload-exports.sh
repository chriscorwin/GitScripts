#!/bin/bash


echo ${I}"####################################################################################"
echo "Upload to dev, qa, and staging? y ${COL_CYAN}(n)${I} "
echo "####################################################################################"${X}
read YorN
if [ "$YorN" = "y" ] || [ "$YorN" = "Y" ]
	then
	echo ""
	echo "builds_path; // " ${builds_path}
	echo ""
	echo ${O}"------------------------------------------------------------------------------------"
	echo "Uploading..."
	echo "------------------------------------------------------------------------------------"
	ant ${ANT_ARGS} upload-all-exports -buildfile ${builds_path}all-remotes.build.xml ;
	echo "------------------------------------------------------------------------------------"${X}
fi


