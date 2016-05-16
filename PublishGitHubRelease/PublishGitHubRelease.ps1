[cmdletbinding()]
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
Write-Verbose -Verbose "assetsPattern = $assetsPattern"

function GetEndpointData
{
	param([string][ValidateNotNullOrEmpty()]$connectedServiceName)

	$serviceEndpoint = Get-ServiceEndpoint -Context $distributedTaskContext -Name $connectedServiceName

	if (!$serviceEndpoint)
	{
		throw "A Connected Service with name '$ConnectedServiceName' could not be found.  Ensure that this Connected Service was successfully provisioned using the services tab in the Admin UI."
	}

    return $serviceEndpoint
}

# Convert checkbox params to booleans
[bool]$draftBool= Convert-String $draft Boolean
[bool]$prereleaseBool= Convert-String $prerelease Boolean

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Import PublishGitHubRelease assembly
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pathToModule = Join-Path $scriptDir "PublishGitHubRelease.dll"
import-module $pathToModule

# Travers all matching files
$assets = Find-Files -SearchPattern $assetsPattern
Write-Verbose -Verbose "assets = $assets"

if ($gitSourceOption -eq "repository"){
	Write-Verbose -Verbose "BUILD_REPOSITORY_PROVIDER = $($Env:BUILD_REPOSITORY_PROVIDER)"

	$gitServiceEndpointName = $($Env:BUILD_REPOSITORY_NAME)
	Write-Verbose -Verbose "Getting $gitServiceEndpointName service..."
	$gitServiceEndpoint = GetEndpointData $gitServiceEndpointName

	if ($($Env:BUILD_REPOSITORY_PROVIDER) -eq "GitHub"){
		$gitSourceOption = "github"
	}else{
		$gitSourceOption = "external"
	}

	$gitSourceUrl = $($gitServiceEndpoint.Url)
	$token = $($gitServiceEndpoint.Authorization.Parameters.Password)
	$repo = $($Env:BUILD_REPOSITORY_NAME)

	Write-Verbose -Verbose "Repository gitSourceOption = $gitSourceOption"
	Write-Verbose -Verbose "Repository gitSourceUrl = $gitSourceUrl"
	Write-Verbose -Verbose "Repository token = $token"
	Write-Verbose -Verbose "Repository repo = $repo"
}

Publish-GitHubRelease -ApplicationName $applicationName -GitSourceOption $gitSourceOption -GitSourceUrl $gitSourceUrl -Token $token -Repo $repo -Owner $owner -TagName $tagName -ReleaseName $releaseName -ReleaseBody $releaseBody -Draft $draftBool -PreRelease $prereleaseBool -Assets $assets
