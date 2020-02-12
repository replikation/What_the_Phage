#!/usr/bin/env python

'''
python cut.py \
    --size 3000 --genome genome.fasta --outfile genome.fragments.fasta
'''


import argparse
import uuid

import screed  # will have been installed alongside sourmash


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument(
    '--genome', required=True, help='Genome to be cut (fasta)')
parser.add_argument(
    '--outfile', required=True, help='Where to save fragments (fasta)')
parser.add_argument(
    '--size', default=3000, type=int, help='Fragment size')
args = parser.parse_args()


def chunks(l, n):
    '''
    Yield successive n-sized chunks from l (stackoverflow, 312443).

    a = [1, 2, 3, 4]
    list(chunks(a, 2))
    # [[1, 2], [3, 4]]

    Returns empty list if list empty.

    For overlapping chunks, see windows()
    '''
    for i in range(0, len(l), n):
        yield l[i:i + n]


with open(args.outfile, 'w+') as out:
    for record in screed.open(args.genome):
        if len(record.sequence) > args.size:
            fragments = [''.join(i) for i in chunks(
                record.sequence, args.size)]
            # The last chunk is likely not <size> nt, so we'll add a chunk from
            # then end to nevertheless include the last nt but still have a
            # fragment of <size>.
            fragments.append(record.sequence[-3000:])
            for f in fragments:
                out.write(f'>{record.name},{str(uuid.uuid4())}\n{f}\n')






