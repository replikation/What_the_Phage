grep "withLabel:" $1 | cut -f2 -d "'" > .container_list.tmp

while read container; do
	docker pull ${container}
done < ".container_list.tmp"