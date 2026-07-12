[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyyMMddHHmmssfff'

function Install-ManagedPath {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Missing source: $Source"
    }

    $sourcePath = [IO.Path]::GetFullPath($Source)
    $targetPath = [IO.Path]::GetFullPath($Target)
    $comparison = [StringComparison]::OrdinalIgnoreCase
    if ($sourcePath.Equals($targetPath, $comparison) -or
        $sourcePath.StartsWith($targetPath.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar, $comparison)) {
        throw "Source $Source is inside managed target $Target; move the repository first."
    }

    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($null -ne $item) {
        if ($item.LinkType -and
            ($item.Target | Where-Object {
                [IO.Path]::GetFullPath($_).Equals($sourcePath, $comparison)
            })) {
            Write-Host "Already linked $Target"
            return
        }

        $backup = "$Target.backup.$stamp"
        $suffix = 0
        while (Test-Path -LiteralPath $backup) {
            $suffix++
            $backup = "$Target.backup.$stamp.$suffix"
        }
        if ($DryRun) {
            Write-Host "Would back up $Target to $backup"
        } else {
            Move-Item -LiteralPath $Target -Destination $backup
            Write-Host "Backed up $Target to $backup"
        }
    }

    if ($DryRun) {
        Write-Host "Would link $Target -> $Source"
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    $sourceItem = Get-Item -LiteralPath $Source
    # Junctions and hard links work without elevation or Windows Developer Mode.
    $linkType = if ($sourceItem.PSIsContainer) { 'Junction' } else { 'HardLink' }
    New-Item -ItemType $linkType -Path $Target -Target $Source | Out-Null
    Write-Host "Linked $Target -> $Source"
}

if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    throw 'LOCALAPPDATA is not set.'
}
if ([string]::IsNullOrWhiteSpace($HOME)) {
    throw 'HOME is not set.'
}

$homeSource = Join-Path $PSScriptRoot 'home'
$paths = @(
    @{
        Source = Join-Path $homeSource '.config\nvim'
        Target = Join-Path $env:LOCALAPPDATA 'nvim'
    },
    @{
        Source = Join-Path $homeSource '.gitconfig'
        Target = Join-Path $HOME '.gitconfig'
    },
    @{
        Source = Join-Path $homeSource '.pixi\manifests\pixi-global.toml'
        Target = Join-Path $HOME '.pixi\manifests\pixi-global.toml'
    }
)

foreach ($path in $paths) {
    Install-ManagedPath -Source $path.Source -Target $path.Target
}

Write-Host "`nConfiguration deployed; package installation remains explicit."
