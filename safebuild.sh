#!/bin/bash
#This safely builds your docker image in a subdirectory inserting all variables found in .env files
#Requirements: docker, moreutils
#TODO: remove existing dir?, ignore .git & $Image
Image=$1

echo Starting Safe Build...
#rm -r $Image
mkdir $Image
cp * $Image
cp .* $Image
cd $Image
source *.env
export $(cut -d= -f1 *.env)
rm -r *.env
for file in * ; do envsubst < $file | sponge $file ; done
for file in .* ; do envsubst < $file | sponge $file ; done
sudo docker build -t $Image .
cd ..
rm -r $Image
echo Done With Safe Build!