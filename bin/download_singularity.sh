grep "withLabel:" $1 | cut -f2 -d "'" > .container_list.tmp
cachedir="$2"

while read container; do
	singularity pull --dir $cachedir docker://${container}
done < ".container_list.tmp"