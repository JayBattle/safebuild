#This safely builds your docker image in a subdirectory inserting all variables found in env.ps1 files
#Syntax: C:\PATH_TO_SCRIPT\safebuild.ps1 IMAGENAME
#env.ps1 example: $Env:SaltMasterIP="172.17.0.2"
#Special Cases: Escape $ with $\
#Special Cases: Double Wrap env vars values in .ps1 in brackets $Env:ET="${{ET}}"
#Special Cases: Wrap multi variable lines in double brackets java ${{ET_FRONTEND_URL} ${EXTRA_OPTS}}
$Image=$args[0]

Write-Host Starting Safe Build...
if (Test-Path -Path $Image) {
    Remove-Item $Image -Recurse -Force
}
New-Item -Name $Image -ItemType "directory"
Copy-Item -Path "./*" -Destination $Image -Recurse -Force -Exclude $Image
Copy-Item  -Path ".*" -Destination $Image
Set-Location $Image
$Files = Get-ChildItem ./*
foreach ($file in $Files) {
    (Get-Content $file -Raw) -replace '\$Env:(.+)' , '$$$1' | Set-Content $file #Remove Powershell Declaration Env Tags
    (Get-Content $file -Raw) -replace '\${(.+)}' , '$$$1' | Set-Content $file #Remove Brackets
    (Get-Content $file -Raw) -replace '\$(\w+)' , '$$env:$1' | Set-Content $file #Add Powershell Command-Line env tags
    (Get-Content $file -Raw) -replace '\$\\(\w+)' , '$$$1' | Set-Content $file #Setup Escaped $'s
}
./*vars.ps1 #create enviornemnt variables for reference (not passed to docker builds)
$VarFiles = Get-ChildItem ./*vars.ps1
foreach ($varFile in $Varfiles) {
    $vars = (Get-ChildItem -Path $varFile | Select-String -Pattern '\$env:(?<key>\w+)="(?<env>.*)"').matches
    foreach ($var in $vars) {
        foreach ($file in $Files) {
            $replaceRegex = '\$env:' + $var.groups[1].value
            (Get-Content $file -Raw) -replace $replaceRegex , $var.groups[2].value | Set-Content $file #replace key w/ value
        }
    }
}
docker build -t $Image . #--no-cache
Set-Location ..
Remove-Item $Image -Recurse -Force
Write-Host Done With Safe Build!