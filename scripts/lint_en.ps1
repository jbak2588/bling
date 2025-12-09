try {
    $path = Join-Path $PSScriptRoot '..\assets\lang\en.json'
    $full = (Resolve-Path $path -ErrorAction Stop).Path
    $json = Get-Content -Raw -Path $full -ErrorAction Stop
    $null = ConvertFrom-Json -InputObject $json -ErrorAction Stop
    Write-Host "OK: $full"
    exit 0
} catch {
    if (-not $full) { $full = 'assets/lang/en.json' }
    Write-Host "ERROR: $full - $($_.Exception.Message)"
    exit 2
}
