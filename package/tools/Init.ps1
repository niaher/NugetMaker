param($installPath, $toolsPath, $package)

$solutionDir = "$($installPath)\..\..\"
$configDestination = "$solutionDir\NugetMaker.json"
$configExists = Test-Path $configDestination

if ($configExists -eq $false)
{
	Copy-Item "$toolsPath\NugetMaker.default.json" -Destination $configDestination
}

Import-Module (Join-Path $toolsPath NugetMaker.psm1)