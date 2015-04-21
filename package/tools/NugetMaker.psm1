function Build-Packages
{
	param (
		[Parameter(Mandatory=$false)]
		[string]$Project
	)

	$config = Get-Content -Raw -Path NugetMaker.json | ConvertFrom-Json
	$projects = $config.projects

	# Remove previously built packages.
	Remove-Item *.nupkg

	# Get solution directory.
	$solutionDir = Split-Path $dte.Solution.FileName -Parent
	$currentDir = "$solutionDir"

	# Get NuGet handle.
	$nuget = "$solutionDir\.nuget\NuGet.exe"

	foreach ($project in $projects | where {$_ -like "*$Project*"})
	{
		Write-Host "`r`nBuilding '$project' package..." -ForegroundColor 'green' -BackgroundColor 'black'

		$projectDir = "$solutionDir\$project"

		# Make sure .nuspec file exists.
		cd $projectDir
		&$nuget spec -Verbosity quiet
		cd $currentDir

		# Build package.
		&$nuget pack "$projectDir\$project.csproj" `
			-OutputDirectory "$currentDir" `
			-Build `
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
		[string]$Target
	)

	$solutionDir = Split-Path $dte.Solution.FileName -Parent
	$packagesDir = "$solutionDir"

	# Get NuGet handle.
	$nuget = "$solutionDir\.nuget\NuGet.exe"

	$packages = Get-ChildItem -Path $packagesDir -Filter '*.nupkg' -Exclude '*.symbols.nupkg' -Recurse
	
	# By default push to remote.
	$Target = if ($Target) { $Target } else { "remote" }
	
	$config = Get-Content -Raw -Path NugetMaker.json | ConvertFrom-Json
	$destination = $config.targets | select -ExpandProperty $Target
	
	foreach ($package in $packages)
	{
		Write-Host "`r`nPushing '$package' package to '$destination'..." -ForegroundColor 'green' -BackgroundColor 'black'
		
		if ($ApiKey)
		{
			&$nuget push $package -ApiKey $ApiKey
		}
		else 
		{
			&$nuget push $package -source $destination
		}
	}
}
	
Export-ModuleMember Build-Packages
Export-ModuleMember Push-Packages