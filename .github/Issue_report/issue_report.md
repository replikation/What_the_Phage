---
name: Error or bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: mult1fractal

---

1-2 sentences about what went wrong

## Command used

* Please provide the full command  that caused the bug
* make sure that you are using a release candidate (`-r` flag, e.g. `-r v1.0.1`)

```bash
# paste here the command used that created the error, e.g.
nextflow run replikation/What_the_Phage -r v1.0.1 -profile local,docker \
  --fasta /fo/bar/test.fasta \
  --dv \
  --mp \
  --vn \
  --output results
```

## Error code

```bash
# paste here the complete error code from the terminal
```

## Additional error code
* nextflow provides a more detailed `.command.log` file which helps us to identify the issue faster
* usually you should have a red terminal print telling you exactly where to find it

```bash
# when a process failed it looks like this:
[cd/06b6d2] process > identify_fasta_MSF:samtools[100%] 1 of 1, failed: 1 ✘
# and you get a red error message showing a long path like this:
Work dir: 
 /work/nextflow-phages-mike/cd/06b6d296eb9e11359493be101688ed
```
* copy the content in this issue via: 
```
cat  /work/nextflow-poreCov-replikation/cd/06b6d2*/.command.log
```

## More Context
Computer specs if you are running locally (not in the cloud or a cluster)

> OPERATING_SYSTEM = e.g. ubuntu 
> THREADS =  4 threads
> RAM = 8 GB RAM
## Additional Inforamtion
If you know what the problem is or tried out a few things let us now