#This safely builds your docker image in a subdirectory inserting all variables found in .env files
#Syntax: safebuild.ps1 IMAGENAME  
$Image=$args[0]

Write-Host Starting Safe Build...
New-Item -Name $Image -ItemType "directory"

Copy-Item -Path "./*" -Destination $Image -Recurse -Force -Exclude $Image
Copy-Item  -Path ".*" -Destination $Image
Set-Location $Image
#source *.env
#export $(cut -d= -f1 *.env)
#for file in * ; do envsubst < $file | sponge $file ; done
#for file in .* ; do envsubst < $file | sponge $file ; done
docker build -t $Image .
Set-Location ..
#Remove-Item -r $Image
Write-Host Done With Safe Build!