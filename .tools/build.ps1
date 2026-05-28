# Konfiguration
$ScriptRoot = $PSScriptRoot
$SourceFolder = Split-Path -Parent $ScriptRoot
$WoWRoot = $env:WOW_ROOT
$IniPath = Join-Path $ScriptRoot "build.ini"

if (-not $WoWRoot -or -not (Test-Path $WoWRoot)) {
	throw "Umgebungsvariable WOW_ROOT ist nicht gesetzt oder zeigt auf ein ungültiges Verzeichnis."
}
if (-not (Test-Path $IniPath)) {
	throw "INI-Datei nicht gefunden: $IniPath"
}

# INI-Datei lesen
$IniContent = Get-Content $IniPath | Where-Object { $_ -notmatch '^\s*($|#|;)' }

$TargetVariants = @()
$Placeholders = @{}
$currentSection = ""

foreach ($line in $IniContent) {
	$trimmedLine = $line.Trim()

	if ($trimmedLine -match '^\[(.+)\]') {
		$currentSection = $matches[1].ToLower()
		continue
	}

	if ($trimmedLine -match "^\s*([^=]+?)\s*=\s*(.+)$") {
		$key = $matches[1].Trim()
		$val = $matches[2].Trim()

		switch($currentSection) {
			"targets" {
				$TargetVariants += $val
			}
			"placeholders" {
				if ($val -match "^\{date:(.+)\}$") {
					$format = $matches[1]
					$val = Get-Date -Format $format
				}
				$Placeholders[$key] = $val
			}
			default {
			}
		}
	}
}

# Kopieren & Ersetzen
$AddonName = Split-Path $SourceFolder -Leaf
$FileExtensions = @("*.toc")

Write-Host 'Deployment für' $AddonName 'gestartet.'

function Assert-SafeTargetFolder {
	param(
		[string]$TargetFolder,
		[string]$AddOnsFolder,
		[string]$ExpectedFolderName
	)

	$resolvedTargetFolder = [System.IO.Path]::GetFullPath($TargetFolder)
	$resolvedAddOnsFolder = [System.IO.Path]::GetFullPath($AddOnsFolder)
	$addOnsPrefix = $resolvedAddOnsFolder.TrimEnd(
		[System.IO.Path]::DirectorySeparatorChar,
		[System.IO.Path]::AltDirectorySeparatorChar
	) + [System.IO.Path]::DirectorySeparatorChar

	if (-not $resolvedTargetFolder.StartsWith($addOnsPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
		throw "Unsicherer Zielpfad: $resolvedTargetFolder liegt nicht im AddOns-Verzeichnis $resolvedAddOnsFolder."
	}

	if ([System.IO.Path]::GetFileName($resolvedTargetFolder) -ne $ExpectedFolderName) {
		throw "Unsicherer Zielpfad: Erwartet wurde der Addon-Ordner '$ExpectedFolderName', erhalten wurde '$([System.IO.Path]::GetFileName($resolvedTargetFolder))'."
	}

	return $resolvedTargetFolder
}

foreach ($variant in $TargetVariants) {
	$TargetFolder = [System.IO.Path]::Combine($WoWRoot, $variant, "Interface", "AddOns", $AddonName)
	$AddOnsFolder = [System.IO.Path]::Combine($WoWRoot, $variant, "Interface", "AddOns")
	$TargetFolder = Assert-SafeTargetFolder -TargetFolder $TargetFolder -AddOnsFolder $AddOnsFolder -ExpectedFolderName $AddonName

	if (Test-Path $TargetFolder) {
		Get-ChildItem -LiteralPath $TargetFolder -Force | ForEach-Object {
			Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
		}
	} else {
		New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
	}

	$items = Get-ChildItem -Path $SourceFolder -Recurse -Force | Where-Object {
		-not ($_.FullName -match "\\\.")
	}

	foreach ($item in $items) {
		$relativePath = $item.FullName.Substring($SourceFolder.Length).TrimStart('\')
		$destination = Join-Path $TargetFolder $relativePath
		$destinationDir = Split-Path $destination -Parent

		if (-not (Test-Path $destinationDir)) {
			New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
		}

		if (-not $item.PSIsContainer) {
			Copy-Item -Path $item.FullName -Destination $destination -Force
		}
	}

	foreach ($ext in $FileExtensions) {
		$files = Get-ChildItem -Path $TargetFolder -Recurse -Include $ext -File -ErrorAction SilentlyContinue
		foreach ($file in $files) {
			$originalContent = Get-Content $file.FullName -Raw -Encoding UTF8
			$modifiedContent = $originalContent

			foreach ($key in $Placeholders.Keys) {
				$pattern = "@$key@"
				$modifiedContent = $modifiedContent -replace [Regex]::Escape($pattern), $Placeholders[$key]
			}

			if ($modifiedContent -ne $originalContent) {
				$utf8NoBom = New-Object System.Text.UTF8Encoding $false
				[System.IO.File]::WriteAllText($file.FullName, $modifiedContent, $utf8NoBom)
				Write-Host 'Datei ersetzt:' $($file.Name)
			}
		}
	}

	Write-Host 'Deployment für' $variant 'abgeschlossen.'
}

Write-Host 'Deployment für' $AddonName 'erfolgreich abgeschlossen.'
