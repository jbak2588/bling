Set-StrictMode -Version Latest
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

$usedFile = Join-Path $root '..\assets\lang\used_i18n_keys.json' | Resolve-Path -Relative
$used = (Get-Content $usedFile -Raw | ConvertFrom-Json).PSObject.Properties.Name

function Get-JsonKeys($obj, $prefix) {
    $keys = @()
    foreach ($p in $obj.PSObject.Properties) {
        if ($prefix -ne '') { $name = "$prefix.$($p.Name)" } else { $name = $p.Name }
        if ($p.Value -is [System.Management.Automation.PSObject] -or $p.Value -is [System.Collections.Hashtable]) {
            $keys += Get-JsonKeys $p.Value $name
        } elseif ($p.Value -is [System.Object[]]) {
            $keys += $name
        } else {
            $keys += $name
        }
    }
    return $keys
}

$locales = @('en','id','ko')
foreach ($lang in $locales) {
    $file = Join-Path $root "..\assets\lang\$lang.json" | Resolve-Path -Relative
    if (-not (Test-Path $file)) {
        Write-Host "MISSING_FILE:$lang"
        continue
    }
    $raw = Get-Content $file -Raw
    function Get-JsonKeysFromText($text) {
        $lines = $text -split "`n"
        $stack = @()
        $keys = @()
        foreach ($line in $lines) {
            $s = $line.Trim()
            # handle closing braces at start
            while ($s.StartsWith('}')) {
                if ($stack.Count -gt 0) { $stack = $stack[0..($stack.Count-2)] }
                $s = $s.TrimStart('}').Trim()
            }
            if ($s -match '"(?<key>[^"]+)"\s*:\s*\{') {
                $k = $matches['key']
                $stack += $k
            } elseif ($s -match '"(?<key>[^"]+)"\s*:\s*\[') {
                $k = $matches['key']
                $full = if ($stack.Count -gt 0) { ($stack + $k) -join '.' } else { $k }
                $keys += $full
            } elseif ($s -match '"(?<key>[^"]+)"\s*:\s*(.+),?$') {
                $k = $matches['key']
                $full = if ($stack.Count -gt 0) { ($stack + $k) -join '.' } else { $k }
                $keys += $full
            }
            # handle closing braces elsewhere in the line
            $closeCount = ($line.ToCharArray() | Where-Object { $_ -eq '}' }).Count
            for ($i=0; $i -lt $closeCount; $i++) {
                if ($stack.Count -gt 0) { $stack = $stack[0..($stack.Count-2)] }
            }
        }
        return $keys
    }
    try {
        $jsonKeys = Get-JsonKeysFromText $raw
    } catch {
        Write-Host ('FLATTEN_ERROR_' + $lang + ':' + $_.Exception.Message)
        $jsonKeys = @()
    }
    $missing = @()
    foreach ($k in $used) {
        if ($k -notin $jsonKeys) { $missing += $k }
    }
    $outFile = Join-Path $root "..\assets\lang\missing_keys_$lang.txt"
    $missing | Sort-Object | Out-File $outFile -Encoding utf8
    Write-Host ('MISSING_' + $lang + ':' + $missing.Count)
}

Write-Host 'Done.'
