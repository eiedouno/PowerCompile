 Add-Type -AssemblyName PresentationFramework
 Add-Type -AssemblyName System.Windows.Forms
 
# Create Window
$window = New-Object System.Windows.Window
$window.Title = "PowerCompile v1.6"
$window.Width = 500
$window.Height = 400
$window.WindowStartupLocation = "CenterScreen"
$window.ResizeMode = "NoResize"

# Create Grid
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "10"

# Add row definitions
0..16 | ForEach-Object {
    $row = New-Object System.Windows.Controls.RowDefinition
    $row.Height = [System.Windows.GridLength]::Auto
    $grid.RowDefinitions.Add($row)
}

# Folder Label
$lblFolder = New-Object System.Windows.Controls.TextBlock
$lblFolder.Text = "Project Folder:"
$lblFolder.Margin = "0,0,0,5"
[System.Windows.Controls.Grid]::SetRow($lblFolder, 0)
$grid.Children.Add($lblFolder)

# Folder Path + Browse Button
$spFolder = New-Object System.Windows.Controls.StackPanel
$spFolder.Orientation = "Horizontal"
[System.Windows.Controls.Grid]::SetRow($spFolder, 1)

$tbPath = New-Object System.Windows.Controls.TextBox
$tbPath.Width = 380
$tbPath.Margin = "0,0,5,0"
$spFolder.Children.Add($tbPath)

$btnBrowse = New-Object System.Windows.Controls.Button
$btnBrowse.Content = "..."
$btnBrowse.Width = 30
$spFolder.Children.Add($btnBrowse)

$grid.Children.Add($spFolder)

# Output File Label
$lblOutput = New-Object System.Windows.Controls.TextBlock
$lblOutput.Text = "Output File:"
$lblOutput.Margin = "0,10,0,5"
[System.Windows.Controls.Grid]::SetRow($lblOutput, 2)
$grid.Children.Add($lblOutput)

# Output File Path
$spOutput = New-Object System.Windows.Controls.StackPanel
$spOutput.Orientation = "Horizontal"
[System.Windows.Controls.Grid]::SetRow($spOutput, 3)
$grid.Children.Add($spOutput)
$tbOutput = New-Object System.Windows.Controls.TextBox
$tbOutput.Text = "compiledproject"
$tbOutput.Margin = "0,0,0,5"
$tbOutput.Width = 380
$tbOutput.HorizontalAlignment = "Left"
$spOutput.Children.Add($tbOutput)
$ps1Text = New-Object System.Windows.Controls.TextBlock
$ps1Text.Text = ".ps1"
$ps1Text.Margin = "5,0,0,0"
$spOutput.Children.Add($ps1Text)

# Embed Modules Checkbox
$chkEmbed = New-Object System.Windows.Controls.CheckBox
$chkEmbed.Content = "Embed .psd1 as base64"
$chkEmbed.Margin = "0,10,0,0"
[System.Windows.Controls.Grid]::SetRow($chkEmbed, 4)
$grid.Children.Add($chkEmbed)

# Compile to Executable Checkbox
$chkExe = New-Object System.Windows.Controls.CheckBox
$chkExe.Content = "Compile to Executable"
$chkExe.Margin = "0,10,0,0"
[System.Windows.Controls.Grid]::SetRow($chkExe, 5)
$grid.Children.Add($chkExe)

# Executable Show Console Checkbox
$chkExeConsole = New-Object System.Windows.Controls.CheckBox
$chkExeConsole.Content = "Show Console"
$chkExeConsole.Margin = "0,10,0,0"
$chkExeConsole.IsEnabled = $false
$chkExeConsole.Visibility = "Collapsed"
$chkExeConsole.ToolTip = "Shows console window when running the executable."
[System.Windows.Controls.Grid]::SetRow($chkExeConsole, 6)
$grid.Children.Add($chkExeConsole)

# Executable Single File Checkbox
$chkExeSingle = New-Object System.Windows.Controls.CheckBox
$chkExeSingle.Content = "Single File"
$chkExeSingle.Margin = "0,10,0,0"
$chkExeSingle.IsEnabled = $false
$chkExeSingle.Visibility = "Collapsed"
[System.Windows.Controls.Grid]::SetRow($chkExeSingle, 7)
$grid.Children.Add($chkExeSingle)

# Status Label
$global:lblStatus = New-Object System.Windows.Controls.TextBlock
$global:lblStatus.Text = ""
$global:lblStatus.Margin = "0,10,0,0"
$global:lblStatus.Foreground = "Gray"
[System.Windows.Controls.Grid]::SetRow($global:lblStatus, 8)
$grid.Children.Add($global:lblStatus)

# Compile Button
$btnMash = New-Object System.Windows.Controls.Button
$btnMash.Content = "Compile"
$btnMash.Height = 40
$btnMash.Margin = "0,10,0,0"
[System.Windows.Controls.Grid]::SetRow($btnMash, 9)
$grid.Children.Add($btnMash)

# Hook up browse click
$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq "OK") {
        $tbPath.Text = $dlg.SelectedPath
    }
})

# Compile button click
$btnMash.Add_Click({
    $Exe = [bool]$chkExe.IsChecked
    $Embed = [bool]$chkEmbed.IsChecked
    $ExeConsole = [bool]$chkExeConsole.IsChecked
    if ($chkExeSingle.IsChecked) {
        Write-Host "[INFO] Compiling to executable: $exe"
        if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
            Write-Host "[INFO] PS2EXE not found. Downloading module..."
            try {
                Install-Module -Name PS2EXE -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
                Import-Module PS2EXE -Force
                Write-Host "[INFO] PS2EXE module installed and imported."
            } catch {
                Write-Host "Failed to install PS2EXE module: `n$_" -ForegroundColor DarkRed
                Pause
                exit
            }
        } else {
            Import-Module PS2EXE -Force
        }
        if ($ExeConsole) {
            Invoke-PS2EXE -InputFile $($tbOutput.Text) -OutputFile $($tbOutput.Text).exe -NoOutput
        } else {
            Invoke-PS2EXE -InputFile $($tbOutput.Text) -OutputFile $($tbOutput.Text).exe -NoConsole -NoOutput
        }
        Write-Host "[SUCCESS] Executable created: $exe" -ForegroundColor Green
        Pause
        Exit
    }
    if (($tbPath.Text -eq "") -or (-not (Test-Path $tbPath.Text))) {
        $global:lblStatus.Text = "Invalid folder path!"
    } else {
        $global:lblStatus.Text = "Compiling $($tbPath.Text)..."
        .\bin\compile.ps1 -Path $tbPath.Text -Embedpsd1 $chkEmbed.IsChecked -Output "$($tbOutput.Text).ps1" -Exe $Exe -ExeConsole $chkExeConsole.IsChecked
        $global:lblStatus.Text = "Compiled successfully!"
    }
})

# Hook up checkbox click
$chkExe.Add_Click({
    if ($chkExe.IsChecked) {
        $chkExeConsole.Visibility = "Visible"
        $chkExeSingle.Visibility = "Visible"
        $chkExeConsole.IsEnabled = $true
        $chkExeSingle.IsEnabled = $true
        if ($chkExeSingle.IsChecked) {
            $ps1text.Visibility = "Collapsed"
            $lblOutput.Text = "Name of File to convert to EXE:"
        }
    } else {
        $chkExeConsole.Visibility = "Collapsed"
        $chkExeSingle.Visibility = "Collapsed"
        $ps1text.Visibility = "Visible"
        $lblOutput.Text = "Output File:"
        $chkExeConsole.IsEnabled = $false
        $chkExeSingle.IsEnabled = $false
    }
})

$chkExeSingle.Add_Click({
    if ($chkExeSingle.IsChecked) {
        $ps1text.Visibility = "Collapsed"
        $lblOutput.Text = "Name of File to convert to EXE:"
    } else {
        $ps1text.Visibility = "Visible"
        $lblOutput.Text = "Output File:"
    }
})

$window.Content = $grid
$window.ShowDialog() | Out-Null
