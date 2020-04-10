SINGULARITY_IMG_STORE=/s/project/phagehost/workdir/singularity
while read container; do
	name=${container//[\:\_\/]/-}
	echo "$name"
	singularity pull --name $name --dir $SINGULARITY_IMG_STORE docker://$container
done < ~/projects/phagehost/wtp_containers.txt
