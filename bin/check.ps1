param(
    [string]$Path
)

Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "    '@", "'@" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "    `"@", "`"@" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace ".//fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "//fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "./fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "/fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace ".\\fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "\\fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace ".\fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace "\fn", "fn" | Set-Content $Path
Start-Sleep -Milliseconds 400
(Get-Content $Path) -replace '^\s+@echo.*$', "" | Set-Content $Path
Start-Sleep -Milliseconds 400
$matchLine = Get-Content $Path | Where-Object { $_ -match '^\s+Add-Type\s+-AssemblyName.*$' } | Select-Object -Unique
Start-Sleep -Milliseconds 400
$rest = Get-Content $Path | Where-Object { $_ -notmatch '^\s+Add-Type\s+-AssemblyName.*$' }
Start-Sleep -Milliseconds 400
Set-Content $Path -Value @($matchLine, $rest)
Start-Sleep -Milliseconds 400