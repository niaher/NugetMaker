function Get-Config ([string]$path) {
	return (Get-Content -Path $path | Where { $_ -notmatch "^[\s]*//" }) -join ' ' | ConvertFrom-Json
}

function Build-Packages
{
	param (
		[Parameter(Mandatory=$false)]
		[string]$Project
	)

	$config = Get-Config "NugetMaker.json"
	$projects = $config.projects

	# Remove previously built packages.
	Remove-Item *.nupkg

	# Get solution directory.
	$solutionDir = Split-Path $dte.Solution.FileName -Parent
	$currentDir = "$solutionDir"

	# Get NuGet handle.
	$nuget = "$solutionDir\.nuget\NuGet.exe"

	# Clean solution
	$dte.Solution.SolutionBuild.Clean($true)

	foreach ($project in $projects | where {$_ -like "*$Project*"})
	{
		Write-Host "`r`nBuilding '$project' package..." -ForegroundColor 'green' -BackgroundColor 'black'

		$projectDir = "$solutionDir\$project"
		$projectFullName = "$projectDir\$project.csproj"
		
		# Make sure .nuspec file exists.
		cd $projectDir
		&$nuget spec -Verbosity quiet
		cd $currentDir
		
		# Build project
		$dte.Solution.SolutionBuild.BuildProject("Release", $projectFullName, $true)

		# Build package.
		&$nuget pack $projectFullName `
			-OutputDirectory "$currentDir" `
			-Symbols `
			-Properties Configuration=Release
	}
}

function Push-Packages
{
	param (
		[Parameter(Mandatory=$false)]
		[string]$ApiKey,

		[Parameter(Mandatory=$false)]
		[switch]$Local
	)

	$solutionDir = Split-Path $dte.Solution.FileName -Parent
	$packagesDir = "$solutionDir"

	# Get NuGet handle.
	$nuget = "$solutionDir\.nuget\NuGet.exe"

	$packages = Get-ChildItem -Path "$packagesDir\*.nupkg" -Exclude '*.symbols.nupkg'

	# Get config file.
	$configFile = if ($Local) { "NugetMaker.Local.json" } else { "NugetMaker.json" }
	$config = Get-Config $configFile

	# Get push target.
	$destination = $config.target

	foreach ($package in $packages)
	{
		$packageName = [System.IO.Path]::GetFileName($package)
		Write-Host "`r`nPushing '$packageName' to '$destination'..." -ForegroundColor 'green' -BackgroundColor 'black'

		if ($ApiKey)
		{
			&$nuget push $package -source $destination -ApiKey $ApiKey
		}
		else
		{
			&$nuget push $package -source $destination
		}
	}
}

Export-ModuleMember Build-Packages
Export-ModuleMember Push-Packages
