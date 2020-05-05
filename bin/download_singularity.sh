grep "withLabel:" $1 | cut -f2 -d "'"  > .container_list.tmp
cachedir="$2"

while read container; do
	name=${container//[\:\/]/-}

	if [ -e ${cachedir}/${name}.img ]
	then
		echo "${name}.img image exists"
	else
		singularity pull --name ${name}.img --dir "${cachedir}" "docker://${container}"
	fi
	
done < ".container_list.tmp"