FASTA=$1
CPUS=$2

SCORE_HLIKE=$3
SCORE_LIKE=$4
SCOURE_UNLIKE=$5

# get contigIDs (from fasta)
CONTIG_LIST=$(grep ">" $FASTA | tr -d ">")

# calculate average, but with reduce "score" if less than 5 tools
mkdir -p scores/
printf '%s\n' "${CONTIG_LIST[@]}" | xargs -I% -P ${CPUS} \
	bash -c "if [[ \$(grep % *.tsv | wc -l) -gt 5 ]]; then 
			grep -w \"%\" *.tsv | awk '{x+=\$2; next} END{print x/NR}' > \"scores/%_file.txt\" ;
		else 
			grep -w \"%\" *.tsv | awk '{x+=\$2; next} END{print x/5}'  > \"scores/%_file.txt\"; 
		fi"

# chunk contignames by scores via xargs
mkdir -p fasta_chunks
printf '%s\n' "${CONTIG_LIST[@]}" | xargs -I% -P ${CPUS} \
bash -c "if [ \"${SCORE_HLIKE}\" = \"\$(printf \"\$(cat scores/%_file.txt)\\n${SCORE_HLIKE}\\n\" | sort -g | head -1)\" ]; then
		echo \"%\" >> fasta_chunks/highly_likely.list ; 
	elif [ \"${SCORE_LIKE}\" = \"\$(printf \"\$(cat scores/%_file.txt)\\n${SCORE_LIKE}\\n\" | sort -g | head -1)\" ]; then
		echo \"%\" >> fasta_chunks/likely.list ;
	elif [ \"${SCOURE_UNLIKE}\" = \"\$(printf \"\$(cat scores/%_file.txt)\\n${SCOURE_UNLIKE}\\n\" | sort -g | head -1)\" ]; then
		echo \"%\" >> fasta_chunks/unlikely.list ;
	else
		echo \"%\" >> fasta_chunks/not_likely.list
fi"
mkdir -p contigs
# faidx 4 lists into fasta chunks
for chunkfile in fasta_chunks/*.list; do
	category=$(basename -s ".list" $chunkfile)
        while read fastaheader; do    
                samtools faidx ${FASTA} $fastaheader >> contigs/${category}_contigs.fasta
        done < ${chunkfile}
done

