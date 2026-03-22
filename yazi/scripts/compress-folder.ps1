param(
	[Parameter(Mandatory = $true, Position = 0)]
	[string]$TargetPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-UniqueArchivePath {
	param(
		[Parameter(Mandatory = $true)]
		[string]$Directory,

		[Parameter(Mandatory = $true)]
		[string]$BaseName,

		[Parameter(Mandatory = $true)]
		[string]$Extension
	)

	$candidate = Join-Path $Directory ($BaseName + $Extension)
	if (-not (Test-Path -LiteralPath $candidate)) {
		return $candidate
	}

	$index = 1
	while ($true) {
		$candidate = Join-Path $Directory ("{0} ({1}){2}" -f $BaseName, $index, $Extension)
		if (-not (Test-Path -LiteralPath $candidate)) {
			return $candidate
		}
		$index++
	}
}

function Resolve-ArchivePath {
	param(
		[Parameter(Mandatory = $true)]
		[string]$InputName,

		[Parameter(Mandatory = $true)]
		[string]$ParentDirectory
	)

	$name = $InputName.Trim()
	if ([string]::IsNullOrWhiteSpace($name)) {
		throw "Archive name cannot be empty."
	}

	$candidate = if ([System.IO.Path]::IsPathRooted($name)) {
		$name
	} else {
		Join-Path $ParentDirectory $name
	}

	$fullPath = [System.IO.Path]::GetFullPath($candidate)
	$extension = [System.IO.Path]::GetExtension($fullPath)
	if ([string]::IsNullOrWhiteSpace($extension)) {
		$fullPath += ".zip"
	} elseif ($extension -ne ".zip") {
		$fullPath = [System.IO.Path]::ChangeExtension($fullPath, ".zip")
	}

	return $fullPath
}

function Prompt-ArchivePath {
	param(
		[Parameter(Mandatory = $true)]
		[string]$DefaultArchiveName,

		[Parameter(Mandatory = $true)]
		[string]$ParentDirectory
	)

	$inputName = Read-Host ("Archive name [.zip] (default: {0})" -f $DefaultArchiveName)
	if ([string]::IsNullOrWhiteSpace($inputName)) {
		$inputName = $DefaultArchiveName
	}

	return Resolve-ArchivePath -InputName $inputName -ParentDirectory $ParentDirectory
}

function Format-FileSize {
	param(
		[Parameter(Mandatory = $true)]
		[long]$Bytes
	)

	if ($Bytes -lt 1KB) { return "$Bytes B" }
	if ($Bytes -lt 1MB) { return ("{0:N1} KB" -f ($Bytes / 1KB)) }
	if ($Bytes -lt 1GB) { return ("{0:N1} MB" -f ($Bytes / 1MB)) }
	return ("{0:N1} GB" -f ($Bytes / 1GB))
}

function Invoke-7ZipQuietly {
	param(
		[Parameter(Mandatory = $true)]
		[string]$Executable,

		[Parameter(Mandatory = $true)]
		[string]$ArchivePath,

		[Parameter(Mandatory = $true)]
		[string]$SourcePath
	)

	$output = & $Executable a -tzip -mx=9 -bd $ArchivePath $SourcePath 2>&1
	if ($LASTEXITCODE -ne 0) {
		$details = (@($output) | ForEach-Object { "$_" }) -join [Environment]::NewLine
		if ([string]::IsNullOrWhiteSpace($details)) {
			throw "7-Zip failed with exit code $LASTEXITCODE"
		}
		throw "7-Zip failed with exit code $LASTEXITCODE`n$details"
	}
}

$resolved = (Resolve-Path -LiteralPath $TargetPath).Path
if (-not (Test-Path -LiteralPath $resolved -PathType Container)) {
	throw "Folder not found: $TargetPath"
}

$parent = Split-Path -Path $resolved -Parent
$name = Split-Path -Path $resolved -Leaf
$defaultArchiveName = $name + ".zip"
$archive = Prompt-ArchivePath -DefaultArchiveName $defaultArchiveName -ParentDirectory $parent
$archiveDirectory = Split-Path -Path $archive -Parent
if (-not (Test-Path -LiteralPath $archiveDirectory -PathType Container)) {
	throw "Output directory not found: $archiveDirectory"
}

if (Test-Path -LiteralPath $archive) {
	while ($true) {
		$choice = Read-Host "Archive exists. [O]verwrite / [A]uto rename / [C]ancel (default: A)"
		if ([string]::IsNullOrWhiteSpace($choice)) {
			$choice = "A"
		}

		switch ($choice.ToUpperInvariant()) {
			"O" {
				Remove-Item -LiteralPath $archive -Force
				break
			}
			"A" {
				$archiveBaseName = [System.IO.Path]::GetFileNameWithoutExtension($archive)
				$archive = Get-UniqueArchivePath -Directory $archiveDirectory -BaseName $archiveBaseName -Extension ".zip"
				break
			}
			"C" {
				Write-Host "Cancelled."
				exit 0
			}
		}
	}
}

$sevenZip = @(
	(Get-Command 7z -ErrorAction SilentlyContinue),
	(Get-Command 7z.exe -ErrorAction SilentlyContinue),
	(Get-Command 7zz -ErrorAction SilentlyContinue),
	(Get-Command 7zz.exe -ErrorAction SilentlyContinue)
) | Where-Object { $_ } | Select-Object -First 1

if ($sevenZip) {
	Invoke-7ZipQuietly -Executable $sevenZip.Source -ArchivePath $archive -SourcePath $resolved
} else {
	Compress-Archive -LiteralPath $resolved -DestinationPath $archive -CompressionLevel Optimal
}

$archiveInfo = Get-Item -LiteralPath $archive
Write-Host ("Created archive: {0}" -f $archiveInfo.FullName)
Write-Host ("Size: {0}" -f (Format-FileSize -Bytes $archiveInfo.Length))
