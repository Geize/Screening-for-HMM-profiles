# Aarhus Universtiy
#@uthor:Geizecler Tomazetto, Ph.D.
#email:geizetomazetto@gmail.com


######## Screening CAZymes in protein fasta files ########
# Directory with your protein fasta files.
# HMM search installed.
# Download the hmmscan-parser.sh and HMM profile (dbCAN database).
# Create the local database.
# Run HMMER package.
# Set up the parameters for Bacteria/Fungi.

##########################################################

import os
import glob


# Pull in all files with .fasta
Files=glob_wildcards("{name}.fasta")

# extract the {name} values into a list
NAMES = Files.name


rule all:
    input:
    #hmmpress - construct binary compressed datafiles for hmmscan.
         expand("HMMProfile.txt.{extension}", extension=['h3f', 'h3i', 'h3m','h3p']),

    #hmmscan - search protein sequences against collections of protein profiles.
         expand("{name}.out",name=NAMES),
         expand("{name}.out.dm",name=NAMES),

    #filter_domtblout --domtblout output from hmmscan for results
         expand("{name}.out.dm.ps",name=NAMES),

    #Filter - set up for Fungi.
         expand("{name}.txt",name=NAMES)



rule hmmpress:
    input:
         input_file="HMMProfile.txt"
    output:
         database=expand("HMMProfile.txt.{extension}",extension=['h3f', 'h3i', 'h3m','h3p'])

    shell:
         '''
         hmmpress {input.input_file}
         '''

rule hmmscan:
    input:
         fasta_files="{name}.fasta"

    output:
         File_dm="{name}.out.dm",
         File_out="{name}.out"
    threads:
         24
    params:
         database="HMMProfile.txt"

    shell:
         '''
         hmmscan --cpu {threads} --domtblout  {output.File_dm} {params.database} {input.fasta_files} > {output.File_out}
         '''


rule filter_domtblout:
    input:
         File_dm="{name}.out.dm"
    output:
         File_ps="{name}.out.dm.ps"
    threads:
         6

    shell:
         '''
         ~/hmmscan-parser.sh {input.File_dm}  > {output.File_ps}
         '''

rule Second_filter:
    input:
         File_ps="{name}.out.dm.ps"
    output:
        Final_file="{name}.txt"
    shell:
         '''
         cat {input.File_ps} | awk '$5<1e-17&&$10>0.45' > {output.Final_file}
         '''
