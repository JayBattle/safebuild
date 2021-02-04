#!/bin/bash
#This safely builds your docker image in a subdirectory inserting all variables found in .env files
#Requirements: docker, moreutils
#TODO: remove existing dir
Image=$1

echo Starting Safe Build...
mkdir $Image
cp * $Image
cp .* $Image
cd $Image
source *.env
export $(cut -d= -f1 *.env)
for file in * ; do envsubst < $file | sponge $file ; done
for file in .* ; do envsubst < $file | sponge $file ; done
docker build -t $Image .
cd ..
rm -r $Image
echo Done With Safe Build!