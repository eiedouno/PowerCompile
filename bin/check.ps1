param(
    [string]$Path
)

# Define replacements up front
$replacements = @{
    "    '@"      = "'@"
    "    `"@"     = "`"@"
    ".//fn"       = "fn"
    "//fn"        = "fn"
    "./fn"        = "fn"
    "/fn"         = "fn"
    ".\\fn"       = "fn"
    "\\fn"        = "fn"
    ".\fn"        = "fn"
    "\fn"         = "fn"
}

# Create a temp file to write to
$tempPath = [System.IO.Path]::GetTempFileName()

# Create StreamReader and StreamWriter
$reader = [System.IO.StreamReader]::new($Path)
$writer = [System.IO.StreamWriter]::new($tempPath, $false, [System.Text.Encoding]::UTF8)

try {
    $addTypeLine = $null
    $restLines = @()

    while (($line = $reader.ReadLine()) -ne $null) {
        # Remove @echo lines
        if ($line -match '^\s*@echo.*$') {
            continue
        }

        # Check for Add-Type (and capture it once)
        if (-not $addTypeLine -and $line -match '^\s*Add-Type\s+-AssemblyName.*$') {
            $addTypeLine = $line
            continue
        }

        # Apply all replacements
        foreach ($pair in $replacements.GetEnumerator()) {
            $line = $line -replace [regex]::Escape($pair.Key), $pair.Value
        }

        $restLines += $line
    }

    # Write lines: Add-Type first if found, then the rest
    if ($addTypeLine) {
        $writer.WriteLine($addTypeLine)
    }

    foreach ($processedLine in $restLines) {
        $writer.WriteLine($processedLine)
    }
}
finally {
    $reader.Close()
    $writer.Close()
}

# Replace original file with cleaned one
[System.IO.File]::Copy($tempPath, $Path, $true)
Remove-Item $tempPath
