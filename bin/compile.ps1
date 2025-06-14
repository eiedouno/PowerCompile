Param(
    [string]$Path,
    [bool]$Embedpsd1 = $false,
    [string]$Output = "compiledproject.ps1",
    [bool]$Exe = $false,
    [bool]$ExeConsole = $false,
    [bool]$Err = $true,
    [string]$SFN
)

if (-not $SFN -or $SFN -eq "" -or [string]::IsNullOrWhiteSpace($SFN)) {
    $SFN = "{STARTING_SCRIPT_NAME}"
    Write-Host "[DEBUG] No SFN identified. Using SFN placeholder." -ForegroundColor DarkMagenta
} else {
    Write-Host "[DEBUG] SFN set: $SFN" -ForegroundColor DarkMagenta
}

# Helper: Sanitize file path to valid function name
function Convert-PathToFunctionName {
    param(
        [string]$FullPath,
        [string]$BasePath
    )
    # Compute relative path and remove extension
    $relative = $FullPath.Substring($BasePath.Length).TrimStart('\','/')
    $name = [IO.Path]::ChangeExtension($relative, $null)
    if ($Err) {
        $clean = ($name -replace '[\\/:\.\s]', '-').ToLower().TrimEnd('-')
        Write-Host "[DEBUG] Function converted: fn-$clean" -ForegroundColor DarkMagenta
        return "fn-$clean"
    } else {
        Write-Host "[DEBUG] Function converted: fn-$name" -ForegroundColor DarkMagenta
        return "fn-$name"
    }
}

# Scan and order project files
function Get-ProjectFiles {
    param(
        [string]$BasePath
    )
    $fileTypes = @('*.psd1','*.psm1','*.ps1','*.bat','*.cmd')
    $files = foreach ($pattern in $fileTypes) {
        Get-ChildItem -Path $BasePath -Recurse -Filter $pattern -File | Sort-Object FullName
    }
    foreach ($tefile in $files) {
        Write-Host "[INFO] Found $tefile" -ForegroundColor "Blue"
    }
    return $files
}

Write-Host "[INFO] Scanning path: $Path"
$allFiles = Get-ProjectFiles -BasePath $Path
if (-not $allFiles) {
    throw "No files found in $Path"
}

# Build mapping: full path to function name, and relative paths for call rewrites
$map = @{}
$relativeMap = @{}
foreach ($file in $allFiles) {
    $fn = Convert-PathToFunctionName -FullPath $file.FullName -BasePath $Path
    $map[$file.FullName] = $fn
    # Prepare relative variations for replacement
    $relPath = $file.FullName.Substring($Path.Length).TrimStart('\','/')
    $key1 = ".\$relPath"
    $key2 = $relPath
    $relativeMap[$key1] = $fn
    $relativeMap[$key2] = $fn
}

# Start bundling
Write-Host "[INFO] Compiling scripts"
$out = @()
$out += "# Auto-generated by PowerCompile"
$out += "# Bundle of project at $Path"
$out += "# You still have to call the first function. e.g.: fn-{STARTING_SCRIPT_NAME}`n"

foreach ($file in $allFiles) {
    $fnName = $map[$file.FullName]
    $ext = $file.Extension.ToLower()
    $content = Get-Content -Raw -LiteralPath $file.FullName

    $out += "function $fnName {"
    if ($Embedpsd1.IsPresent -and $ext -eq '.psd1') {
        # Embed PSD1 as Base64
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        $b64 = [Convert]::ToBase64String($bytes)
        $out += "    # Embedded base64 of $($file.Name)"
        $out += "    \$b64 = '$b64'"
        $out += "    [IO.File]::WriteAllBytes('$($file.Name)', [Convert]::FromBase64String(\$b64))"
    }
    elseif ($ext -eq '.psm1' -or $ext -eq '.ps1' -or $ext -eq '.bat' -or $ext -eq '.cmd') {
        # Rewrite internal calls and indent lines
        foreach ($line in $content -split "`r?`n") {
            $modified = $line
            foreach ($key in $relativeMap.Keys) {
                $modified = $modified -replace [regex]::Escape($key), $relativeMap[$key]
            }
            $out += "    $modified"
        }
    }
    $out += "}"  # Closing function
    $out += ""  # Blank line
}

Write-Host "[SUCCESS] Compile complete." -ForegroundColor Green
Write-Host "[INFO] Writing compiled script to $Output"
$out | Set-Content -LiteralPath $Output -Encoding UTF8
Write-Host "[SUCCESS] Write complete. Output: $Output" -ForegroundColor Green

if ($Err -eq "True") {
    Write-Host "[INFO] Scanning for Errors"
    .\bin\check.ps1 -Path $Output
    Write-Host "[SUCCESS] Preformed Error Handling on $Output" -ForegroundColor Green
}

$SFN = $SFN.Replace(".\\", "")
$SFN = $SFN.Replace("\\", "")
$SFN = $SFN.Replace(".\", "")
$SFN = $SFN.Replace(".//", "")
$SFN = $SFN.Replace("//", "")
$SFN = $SFN.Replace("./", "")
$SFN = $SFN.Replace(".cmd", "")
$SFN = $SFN.Replace(".bat", "")
$SFN = $SFN.Replace(".ps1", "")
$SFN = $SFN.Replace(".psm1", "")
$SFN = $SFN.Replace("/", "-")
$SFN = $SFN.Replace("\", "-")
$SFN = if ($SFN.StartsWith('-')) { $SFN.Substring(1) } else { $SFN }
Add-Content -Path $Output -Value "`n# Starting Function:"
Add-Content -Path $Output -Value "`nfn-$SFN"

if ($exe -eq "True") {
    Write-Host "[INFO] Compiling to executable: $exe"
    if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
        Write-Host "[WARNING] PS2EXE not found. Downloading module..." -ForegroundColor Yellow
        try {
            Install-Module -Name PS2EXE -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Import-Module PS2EXE -Force
            Write-Host "[INFO] PS2EXE module installed and imported."
        } catch {
            throw "[ERROR] Failed to install PS2EXE module: `n$_"
        }
    } else {
        Import-Module PS2EXE -Force
    }
    if ($ExeConsole) {
        Invoke-PS2EXE -InputFile $Output -OutputFile $($Output).exe
    } else {
        Invoke-PS2EXE -InputFile $Output -OutputFile $($Output).exe -NoConsole -NoOutput
    }
    Write-Host "[SUCCESS] Executable created: $exe" -ForegroundColor Green
}

Write-Host "[WARNING] Ensure to review the output script for any potential issues." -ForegroundColor Yellow