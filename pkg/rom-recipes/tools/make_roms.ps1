#!/usr/bin/pwsh -Command

$coreName = "digdug"
$currentPath = $(Get-Item $($MyInvocation.MyCommand.Path)).DirectoryName
$fileNames = Get-ChildItem -Path "$currentPath\..\xml" -Recurse -Include *.mra

try { 
    foreach ($f in $fileNames){
        $outfile = $f.FullName
        Write-Host "Converting $outfile ..."
        orca.exe -z ..\roms -O ..\Assets\$coreName\common $outfile
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
} finally {
    Write-Host "Done."
    Write-Host "Copy your rom files to Assets/$coreName/common"
    Write-Host "Enjoy!"
    timeout /t 10
}

exit 0
