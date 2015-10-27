#!/bin/bash
# It is easier to maintain a different script for the reference genome, because this uses a different checksum command, and
# gets the files feeded from the checksum file prodivded by ensembl.
# The script is not tested with BWA. There is room to update for the files to be BWA ready.
#Script downloads the genome from the Gorilla. Location can be provided in the variable below.
BaseUrl="ftp://ftp.ensembl.org/pub/release-82/fasta/gorilla_gorilla/dna/"
# FILL ME IN FIRST!
# Could be prodivded by main pipeline.
Path="/media/sf_D_DRIVE/ape/dl_gen/"
`mkdir ${Path}Refgenome`
# for saving the files and using local paths.
cd ${Path}Refgenome

# Downloading checksums
`wget ${BaseUrl}"CHECKSUMS"`
# File for listing failed downloads. This file can be checked in the complete pipeline for missing files. 
# I advice doing this with a simple egrep and exit if there is any file in the failedChromosomes.
touch failedChromosomes

`cat checksums | egrep "Gorilla_gorilla.gorGor3.1.dna.chromosome.[^MT]" > fastalist`

while read line
do
	name="$(echo $line | awk '{print $3}')"
	# if the file does not exists, then do code.
	if [ ! -e "${name}" ]
	then
		#Download file.
		`wget ${BaseUrl}${name}`
		# create a checksum for the downloaded file.
		check="$(sum ${name})"
		# get colums with checksums from line.
		checkfromfile="$(echo ${line} | awk '{print $1, $2}')"
		if [ "$check" = "$checkfromfile" ]
		then
			# if the checksum matches, then extract file from gz.
			`gunzip ${name}`
		else
			# if file doesn't matches, extend the failedChromosomes list.
			echo ${name} >> failedChromosomes
			rm ${name}
		fi
	fi
done < fastalist

echo "Done downloading files."