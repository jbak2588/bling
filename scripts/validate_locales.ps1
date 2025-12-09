$errors = @()
$files = Get-ChildItem -Path ".\assets\lang" -Filter *.json -File -ErrorAction Stop
foreach ($f in $files) {
  Write-Host "Checking: $($f.Name)"
  try {
    $json = Get-Content -Raw -Path $f.FullName -ErrorAction Stop
    # Use ConvertFrom-Json and assign to $null to avoid printing parsed object
    $null = ConvertFrom-Json -InputObject $json -ErrorAction Stop
    Write-Host "OK : $($f.Name)"
  } catch {
    $msg = $_.Exception.Message
    Write-Host "ERROR: $($f.Name) - $msg"

    # try to extract a character position from the message and show a short context
    $pos = $null
    if ($msg -match 'position\s*(\d+)') { $pos = [int]$matches[1] }
    elseif ($msg -match 'at\s*position\s*(\d+)') { $pos = [int]$matches[1] }

    if ($pos -is [int]) {
      try {
        $prefix = $json.Substring(0, [Math]::Min($pos, $json.Length))
        $line = ($prefix -split "\r?\n").Count
        $col = $prefix.Length - ($prefix -split "\r?\n" | Select-Object -Last 1).Length + 1
        $start = [Math]::Max(0, $pos - 50)
        $len = [Math]::Min(200, $json.Length - $start)
        $snippet = $json.Substring($start, $len) -replace "\r?\n", ' '
        Write-Host "  At approx line $line, col $col (char pos $pos):"
        Write-Host "  ...$snippet..."
      } catch {
        # ignore snippet errors
      }
    }

    $errors += @{ file = $f.FullName; message = $msg }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "\nSummary: $($errors.Count) file(s) failed to parse."
  foreach ($e in $errors) { Write-Host "- $($e.file) : $($e.message)" }
  exit 2
} else {
  Write-Host "\nAll locale JSON files parsed successfully."
  exit 0
}