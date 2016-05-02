﻿[cmdletbinding()]
Param(
	[string]$applicationName,
	[string]$gitSourceOption,
	[string]$gitSourceUrl,
	[string]$token,
	[string]$repo,
	[string]$owner,
	[string]$tagName,
	[string]$releaseName,
	[string]$releaseBody,
	[string]$draft,
	[string]$prerelease,
	[string]$assetsOption,
	[string]$assetsPattern
)
Write-Verbose -Verbose "Entering script PublishRelease.ps1"
Write-Verbose -Verbose "applicationName = $applicationName"
Write-Verbose -Verbose "gitSourceOption = $gitSourceOption"
Write-Verbose -Verbose "gitSourceUrl = $gitSourceUrl"
Write-Verbose -Verbose "token = $token"
Write-Verbose -Verbose "repo = $repo"
Write-Verbose -Verbose "owner = $owner"
Write-Verbose -Verbose "tagName = $tagName"
Write-Verbose -Verbose "releaseName = $releaseName"
Write-Verbose -Verbose "releaseBody = $releaseBody"
Write-Verbose -Verbose "draft = $draft"
Write-Verbose -Verbose "prerelease = $prerelease"
Write-Verbose -Verbose "assetsOption = $assetsOption"
Write-Verbose -Verbose "assetsPattern = $assetsPattern"
Write-Verbose -Verbose "version = 0.9.27"

# Convert checkbox params to booleans
[bool]$draftBool= Convert-String $draft Boolean
[bool]$prereleaseBool= Convert-String $prerelease Boolean
[bool]$assetsOptionBool= Convert-String $assetsOption Boolean

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Import PublishGitHubRelease assembly
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pathToModule = Join-Path $scriptDir "PublishGitHubRelease.dll"
import-module $pathToModule

[string[]]$assets = @()
If ($assetsOptionBool -eq $true){
	# Travers all matching files
	$assets = Find-Files -SearchPattern $assetsPattern
Publish-GitHubRelease -ApplicationName $applicationName -GitSourceOption $gitSourceOption -GitSourceUrl $gitSourceUrl -Token $token -Repo $repo -Owner $owner -TagName $tagName -ReleaseName $releaseName -ReleaseBody $releaseBody -Draft $draftBool -PreRelease $prereleaseBool -Assets $assets

Publish-GitHubRelease -ApplicationName $applicationName -GitSourceOption $gitSourceOption -GitSourceUrl $gitSourceUrl -Token $token -Repo $repo -Owner $owner -TagName $tagName -ReleaseName $releaseName -ReleaseBody $releaseBody -Draft $draftBool -PreRelease $prereleaseBool -AssetsOption $assetsOptionBool -Assets $assets
