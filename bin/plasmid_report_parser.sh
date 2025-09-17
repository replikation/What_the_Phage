HTMLINJECT=$2
SVG_LIST=$(ls *.svg)
NAME=$1
HASHID=$3

## First drop down container
### header
printf '\n<select onchange="showImage' > $HTMLINJECT
printf "$HASHID" >> $HTMLINJECT
printf '(this.value)">\n' >> $HTMLINJECT

### content
i=0
while IFS= read -r line; do
	((i++))
	printf ' <option value="image' >> $HTMLINJECT
	printf "${i}_${1}" >> $HTMLINJECT
	printf '">Plasmid-Phage ' >> $HTMLINJECT
	printf "$i" >> $HTMLINJECT
	printf '</option>\n' >> $HTMLINJECT
done <<< "$SVG_LIST"

printf '</select>\n\n' >> $HTMLINJECT

## Image container - one per plasmid - firstcontainer autoshow
i=0
while IFS= read -r line; do
	((i++))
	printf '<div class="image-container' >> $HTMLINJECT
    printf "$HASHID" >> $HTMLINJECT
    printf '" id="image' >> $HTMLINJECT
	printf "${i}_${1}" >> $HTMLINJECT
	if [ $i = "1" ]; then 
		printf '" >\n' >> $HTMLINJECT
	else 
		printf '" style="display:none;">\n' >> $HTMLINJECT
	fi

	printf ' <img src="' >> $HTMLINJECT
	printf "${NAME}_report_plasmids.${i}.svg" >> $HTMLINJECT
	printf '" alt="Plasmid-Phage' >> $HTMLINJECT
	printf "${i}_${1}" >> $HTMLINJECT
	printf '">\n</div>\n\n' >> $HTMLINJECT

    # sort files
    cp $line ${NAME}_report_plasmids.${i}.svg
done <<< "$SVG_LIST"



