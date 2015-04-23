param($installPath, $toolsPath, $package)

function Copy-ItemIfNotExists($source, $destination)
{
	$exists = Test-Path $destination

	if ($exists -eq $false)
	{
		Copy-Item $source -Destination $destination
	}
}

function Add-ProjectItem($solutionFolder, $source)
{
	$name = [System.IO.Path]::GetFileName($source)
	$existingItem = $solutionFolder.ProjectItems | where-object { $_.Name -eq "$name" } | select -first 1

	if (!$existingItem)
	{
		$projectItems = Get-Interface $solutionFolder.ProjectItems ([EnvDTE.ProjectItems])
		$projectItems.AddFromFile($source)
	}
}

function Add-SolutionFolder($solution, $name)
{
	$solutionFolder = $solution.Projects | where-object { $_.ProjectName -eq $name } | select -first 1

	if (!$solutionFolder)
	{
		$solutionFolder = $solution.AddSolutionFolder($name)
	}

	return $solutionFolder
}

$solutionDir = "$($installPath)\..\..\"

# Copy config files to the solution dir.
Copy-ItemIfNotExists "$toolsPath\NugetMaker.json" "$solutionDir\NugetMaker.json"
Copy-ItemIfNotExists "$toolsPath\NugetMaker.Local.json" "$solutionDir\NugetMaker.Local.json"

# Create a new solution folder "NugetMaker" if it doesn't already exist.
$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
$nugetMakerSolutionFolder = Add-SolutionFolder $solution "NugetMaker"

# Add "NugetMaker.json" to the "NugetMaker" solution folder.
Add-ProjectItem $nugetMakerSolutionFolder "$solutionDir\NugetMaker.json"

Import-Module (Join-Path $toolsPath NugetMaker.psm1)
