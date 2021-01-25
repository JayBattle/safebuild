#This safely builds your docker image in a subdirectory inserting all variables found in env.ps1 files
#Syntax: safebuild.ps1 IMAGENAME
#env.ps1 example: $Env:SaltMasterIP = "172.17.0.2"  
$Image=$args[0]

Write-Host Starting Safe Build...
New-Item -Name $Image -ItemType "directory"
Copy-Item -Path "./*" -Destination $Image -Recurse -Force -Exclude $Image
Copy-Item  -Path ".*" -Destination $Image
Set-Location $Image
./*vars.ps1

#TODO: Replace ENV Vars in files for use in container
    #Windows:
        #$f = 'C:\path\to\your.txt'
        #(Get-Content $f -Raw) -replace '\$env:ReplicaOrNewDomain', $env:ReplicaOrNewDomain | Set-Content $f

    #linux:
        #export $(cut -d= -f1 *.env)
        #for file in * ; do envsubst < $file | sponge $file ; done
        #for file in .* ; do envsubst < $file | sponge $file ; done

docker build -t $Image .
Set-Location ..
Remove-Item $Image -Recurse -Force
Write-Host Done With Safe Build!