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

# Start-File Label
$lblssn = New-Object System.Windows.Controls.TextBlock
$lblssn.Text = "Path of the execution script (the one that triggers them all):"
$lblssn.Margin = "5,10,0,0"
$lblssn.Visibility = "Collapsed"
[System.Windows.Controls.Grid]::SetRow($lblssn, 6)
$grid.Children.Add($lblssn)

# Start-File Name
$tbssn = New-Object System.Windows.Controls.TextBox
$tbssn.Margin = "0,10,0,0"
$tbssn.Width = 380
$tbssn.IsEnabled = $false
$tbssn.Visibility = "Collapsed"
$tbssn.ToolTip = "Make sure this file isn't a batch redirect script. (A batch script that starts a powershell file)"
$tbssn.HorizontalAlignment = "Left"
[System.Windows.Controls.Grid]::SetRow($tbssn, 7)
$grid.Children.Add($tbssn)

# Executable Show Console Checkbox
$chkExeConsole = New-Object System.Windows.Controls.CheckBox
$chkExeConsole.Content = "Show Console"
$chkExeConsole.Margin = "0,10,0,0"
$chkExeConsole.IsEnabled = $false
$chkExeConsole.Visibility = "Collapsed"
$chkExeConsole.ToolTip = "Shows console window when running the executable."
[System.Windows.Controls.Grid]::SetRow($chkExeConsole, 8)
$grid.Children.Add($chkExeConsole)

# Executable Single File Checkbox
$chkExeSingle = New-Object System.Windows.Controls.CheckBox
$chkExeSingle.Content = "Single File"
$chkExeSingle.Margin = "0,10,0,0"
$chkExeSingle.IsEnabled = $false
$chkExeSingle.Visibility = "Collapsed"
$chkExeSingle.ToolTip = "Convert to executable an already-compiled Powershell script."
[System.Windows.Controls.Grid]::SetRow($chkExeSingle, 9)
$grid.Children.Add($chkExeSingle)

# Error Checking Checkbox
$chkerr = New-Object System.Windows.Controls.CheckBox
$chkerr.Content = "Preform Error Handling"
$chkerr.Margin = "0,10,0,0"
$chkerr.ToolTip = "Attempt to fix any errors detected after compiling the project."
[System.Windows.Controls.Grid]::SetRow($chkerr, 10)
$grid.Children.Add($chkerr)

# Status Label
$global:lblStatus = New-Object System.Windows.Controls.TextBlock
$global:lblStatus.Text = ""
$global:lblStatus.Margin = "0,10,0,0"
$global:lblStatus.Foreground = "Gray"
[System.Windows.Controls.Grid]::SetRow($global:lblStatus, 11)
$grid.Children.Add($global:lblStatus)

# Compile Button
$btnMash = New-Object System.Windows.Controls.Button
$btnMash.Content = "Compile"
$btnMash.Height = 40
$btnMash.Margin = "0,10,0,0"
[System.Windows.Controls.Grid]::SetRow($btnMash, 12)
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
    $Err = [bool]$chkerr.IsChecked
    $ssn = $tbssn.Text
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
                
            }
        } else {
            Import-Module PS2EXE -Force
        }
        if ($ExeConsole) {
            Invoke-PS2EXE -InputFile $($tbOutput.Text) -OutputFile $($tbOutput.Text).exe
            Write-Host "[SUCCESS] Executable created: $exe" -ForegroundColor Green
        } else {
            Invoke-PS2EXE -InputFile $($tbOutput.Text) -OutputFile $($tbOutput.Text).exe -NoConsole -NoOutput
            Write-Host "[SUCCESS] Executable created: $exe" -ForegroundColor Green
        }
    } else {
        if (($tbPath.Text -eq "") -or (-not (Test-Path $tbPath.Text))) {
            $global:lblStatus.Text = "Invalid folder path!"
        } else {
            $global:lblStatus.Text = "Compiling $($tbPath.Text)..."
            .\bin\compile.ps1 -Path $tbPath.Text -Embedpsd1 $Embed -Output "$($tbOutput.Text).ps1" -Exe $Exe -ExeConsole $ExeConsole -Err $Err -SSN $ssn
            $global:lblStatus.Text = "Compiled successfully!"
        }
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
            $lblFolder.Visibility = "Collapsed"
            $spFolder.Visibility = "Collapsed"
        } else {
            $lblssn.Visibility = "Visible"
            $tbssn.Visibility = "Visible"
            $tbssn.IsEnabled = $true
        }
    } else {
        $lblssn.Visibility = "Collapsed"
        $tbssn.Visibility = "Collapsed"
        $tbssn.IsEnabled = $false
        $chkExeConsole.Visibility = "Collapsed"
        $chkExeSingle.Visibility = "Collapsed"
        $ps1text.Visibility = "Visible"
        $lblFolder.Visibility = "Visible"
        $spFolder.Visibility = "Visible"
        $lblOutput.Text = "Output File:"
        $chkExeConsole.IsEnabled = $false
        $chkExeSingle.IsEnabled = $false
    }
})

$chkExeSingle.Add_Click({
    if ($chkExeSingle.IsChecked) {
        $lblssn.Visibility = "Collapsed"
        $tbssn.Visibility = "Collapsed"
        $tbssn.IsEnabled = $false
        $ps1text.Visibility = "Collapsed"
        $lblOutput.Text = "Name of File to convert to EXE:"
        $lblFolder.Visibility = "Collapsed"
        $spFolder.Visibility = "Collapsed"
        $chkerr.Visibility = "Collapsed"
    } else {
        $lblssn.Visibility = "Visible"
        $tbssn.Visibility = "Visible"
        $tbssn.IsEnabled = $true
        $ps1text.Visibility = "Visible"
        $lblFolder.Visibility = "Visible"
        $spFolder.Visibility = "Visible"
        $chkerr.Visibility = "Visible"
        $lblOutput.Text = "Output File:"
    }
})

$window.Content = $grid
$window.ShowDialog() | Out-Null
