$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    throw 'LOCALAPPDATA is not set.'
}

$source = Join-Path $PSScriptRoot 'home\.config\nvim'
$target = Join-Path $env:LOCALAPPDATA 'nvim'
$sourcePath = [IO.Path]::GetFullPath($source)
$targetPath = [IO.Path]::GetFullPath($target)

if (-not (Test-Path -LiteralPath $source -PathType Container)) {
    throw "Missing Neovim configuration: $source"
}

if ($sourcePath.StartsWith($targetPath + [IO.Path]::DirectorySeparatorChar,
        [StringComparison]::OrdinalIgnoreCase)) {
    throw "Move this repository outside $target before running bootstrap."
}

if (Test-Path -LiteralPath $target) {
    $item = Get-Item -LiteralPath $target
    if ($item.LinkType -and
        ([IO.Path]::GetFullPath($item.Target) -eq $sourcePath)) {
        Write-Host "$target is already linked"
        return
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
if (Test-Path -LiteralPath $target) {
    $stamp = Get-Date -Format 'yyyyMMddHHmmssfff'
    $backup = "$target.backup.$stamp"
    Move-Item -LiteralPath $target -Destination $backup
    Write-Host "Backed up $target to $backup"
}

New-Item -ItemType Junction -Path $target -Target $source | Out-Null
Write-Host "Linked $target -> $source"
