# What is this?
NugetMaker is a tiny NuGet package that will help you create your own NuGet packages.

## Install
```
Install-Package NugetMaker
```

Once installed, your Package Manager Console in Visual Studio will be augmented with 2 commands: `Build-Packages` and `Push-Packages`.


## Build-Packages
This command will build all packages specified inside *$(SolutionDir)/NugetMaker.json*.

```
Build-Packages
```

To build a specific project you can run

```
Build-Packages -Project "Project1"
```

When you run `Build-Packages` command for the first time, a \*.nuspec file will be created for each of your projects. **Initial run will fail because the \*.nuspec file will have some missing information**. You will need to go and edit each *.nuspec file to setup your packages. For more information on how to do that, please see [NuGet documentation][nuspec-docs].


## Push-Packages
This command will publish your pre-built packages. It is as simple as:

```
Push-Packages
```

By default packages will be published to the *remote* (see configuration file inside *$(SolutionDir)/NugetMaker.json*). To publish to a different target you can do this:

```
Push-Packages -Target local
```

However you will need to make sure that the target is specified inside the NugetMaker.json.

## Config - NugetMaker.json
This file contains basic configuration for your solution. When you `Install-Package NugetMaker` the configuration file will be created inside the solution directory. You can then modify its contents to suit your setup. By default it's preconfigured to this:

```
{
	// The list of projects you want to create a NuGet package for.
	// When running `Build-Packages`, all specified projects will be packaged
	// based on their corresponding *.nuspec files (which will be created on the
	// first run).
	// To build package for a specific project you can run `Build-Packages -Project "MyProject1"`.
	// All projects containing the specified string will be built.
	"projects": [
		"MySolution.MyProject1",
		"MySolution.MyProject2"],

	// The target to which you want to push. It can be either a remote server,
	// such as nuget.org or a UNC path (e.g. - "\\remote-computer\c$\Nugets").
	// For UNC path make sure to use either "double-backward-slash" (\\) or a "forward-slash" (/).
	// A "single-backward-slash" (\) is treated as an escape character. So for example,
	// if you want to push to "\\remote-computer\c$\Nugets", your target should be set to
	// "\\\\remote-computer\\c$\\Nugets".
	"target": "http://www.nuget.org/"
}
```

## Config - NugetMaker.Local.json
When you install NugetMaker package, it will automatically create another config file at *$(SolutionDir)/NugetMaker.Local.json*. This file will contain configuration for `Push-Packages -Local` command. The goal is to allow you to test your packages locally before pushing them to nuget.org or other remote server. This file should be ignored
by the source control (git/TFS/etc), because it is only useful on the local machine.

```
{
	// Make sure to use either "double-backward-slash" (\\) or a "forward-slash" (/).
	// A "single-backward-slash" (\) is treated as an escape character.
	"target": "C:\\Nugets"
}
```

Enjoy!

[nuspec-docs]:http://docs.nuget.org/create/nuspec-reference
