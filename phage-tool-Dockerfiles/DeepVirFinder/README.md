# shell command

```bash
dvf.py -c ${CPU} -i ${assembly_name} -o output/
```

Options:

```bash
  -h, --help            show this help message and exit
  -i INPUT_FA, --in=INPUT_FA
                        input fasta file
  -m MODDIR, --mod=MODDIR
                        model directory (default ./models)
  -o OUTPUT_DIR, --out=OUTPUT_DIR
                        output directory
  -l CUTOFF_LEN, --len=CUTOFF_LEN
                        predict only for sequence >= L bp (default 1)
  -c CORE_NUM, --core=CORE_NUM
                        number of parallel cores (default 1)
```

