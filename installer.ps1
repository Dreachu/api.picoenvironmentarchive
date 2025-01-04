Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pico Environments Archive Installation Wizard"
$form.Size = New-Object System.Drawing.Size(350, 350)

# Create the Download Environments button
$downloadButton = New-Object System.Windows.Forms.Button
$downloadButton.Text = "Download Environments"
$downloadButton.Size = New-Object System.Drawing.Size(200, 30)
$downloadButton.Location = New-Object System.Drawing.Point(50, 20)

# Create the Install USB Driver button (Only for the main menu)
$installDriverButton = New-Object System.Windows.Forms.Button
$installDriverButton.Text = "Install USB Driver"
$installDriverButton.Size = New-Object System.Drawing.Size(200, 30)
$installDriverButton.Location = New-Object System.Drawing.Point(50, 60)

# Create the Download Pico Theme Manager button (Main Menu)
$downloadThemeButton = New-Object System.Windows.Forms.Button
$downloadThemeButton.Text = "Download Pico Theme Manager"
$downloadThemeButton.Size = New-Object System.Drawing.Size(200, 30)
$downloadThemeButton.Location = New-Object System.Drawing.Point(50, 100)

# Add the "Install Pico Theme Manager" button to the main menu
$installPicoThemeManagerButton = New-Object System.Windows.Forms.Button
$installPicoThemeManagerButton.Text = "Install Pico Theme Manager"
$installPicoThemeManagerButton.Size = New-Object System.Drawing.Size(200, 30)
$installPicoThemeManagerButton.Location = New-Object System.Drawing.Point(50, 140)
$installPicoThemeManagerButton.Add_Click({
    Install-PicoThemeManager
})

# Create the Exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Size = New-Object System.Drawing.Size(200, 30)
$exitButton.Location = New-Object System.Drawing.Point(50, 180)

# Create the button to download Pico environments (Initially hidden)
$picoButton = New-Object System.Windows.Forms.Button
$picoButton.Text = "Download Pico Environments"
$picoButton.Size = New-Object System.Drawing.Size(200, 30)
$picoButton.Location = New-Object System.Drawing.Point(50, 60)
$picoButton.Visible = $false

# Create the button to download Oculus environments (Initially hidden)
$oculusButton = New-Object System.Windows.Forms.Button
$oculusButton.Text = "Download Oculus Environments"
$oculusButton.Size = New-Object System.Drawing.Size(200, 30)
$oculusButton.Location = New-Object System.Drawing.Point(50, 100)
$oculusButton.Visible = $false

# Create the button to download all environments (Initially hidden)
$allButton = New-Object System.Windows.Forms.Button
$allButton.Text = "Download All Environments"
$allButton.Size = New-Object System.Drawing.Size(200, 30)
$allButton.Location = New-Object System.Drawing.Point(50, 140)
$allButton.Visible = $false

# Create the back button (Initially hidden)
$backButton = New-Object System.Windows.Forms.Button
$backButton.Text = "Back"
$backButton.Size = New-Object System.Drawing.Size(200, 30)
$backButton.Location = New-Object System.Drawing.Point(50, 180)
$backButton.Visible = $false

# Create the progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(250, 30)
$progressBar.Location = New-Object System.Drawing.Point(50, 220)
$progressBar.Visible = $false

# Create the label to show the current downloading environment name
$label = New-Object System.Windows.Forms.Label
$label.Text = ""
$label.Size = New-Object System.Drawing.Size(250, 30)
$label.Location = New-Object System.Drawing.Point(50, 250)
$label.Visible = $false

# Function to check if environments are already downloaded
function Check-EnvironmentExists {
    param ($environment)

    # Define the environments folder path
    $environmentsFolder = Join-Path -Path (Get-Location) -ChildPath "environments"
    $destinationPath = Join-Path -Path $environmentsFolder -ChildPath "$($environment.title).apk"

    return (Test-Path $destinationPath)
}

# Function to download ADB and extract it
function Start-ADBDownload {
    $adbFolderPath = Join-Path -Path (Get-Location) -ChildPath "ADB"
    
    # Check if the ADB folder already exists
    if (Test-Path $adbFolderPath) {
        [System.Windows.Forms.MessageBox]::Show(
            "ADB is already downloaded.",
            "ADB Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        GoToMainMenu
        return
    }

    # ADB download URL
    $adbZipUrl = "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/ADB.zip"
    $adbZipPath = Join-Path -Path (Get-Location) -ChildPath "ADB.zip"

    # Create a new form for the ADB download and extraction process
    $adbDownloadForm = New-Object System.Windows.Forms.Form
    $adbDownloadForm.Text = "Downloading Required Files"
    $adbDownloadForm.Size = New-Object System.Drawing.Size(350, 200)

    $adbDownloadLabel = New-Object System.Windows.Forms.Label
    $adbDownloadLabel.Text = "Downloading ADB..."
    $adbDownloadLabel.Size = New-Object System.Drawing.Size(300, 20)
    $adbDownloadLabel.Location = New-Object System.Drawing.Point(50, 30)

    $adbDownloadProgressBar = New-Object System.Windows.Forms.ProgressBar
    $adbDownloadProgressBar.Size = New-Object System.Drawing.Size(250, 30)
    $adbDownloadProgressBar.Location = New-Object System.Drawing.Point(50, 70)
    $adbDownloadProgressBar.Maximum = 100
    $adbDownloadProgressBar.Value = 0

    $adbDownloadForm.Controls.Add($adbDownloadLabel)
    $adbDownloadForm.Controls.Add($adbDownloadProgressBar)

    # Show the form
    $adbDownloadForm.Show()

    # Download ADB
    Invoke-WebRequest -Uri $adbZipUrl -OutFile $adbZipPath
    $adbDownloadProgressBar.Value = 50
    [System.Windows.Forms.Application]::DoEvents() # Refresh GUI

    # Extract the ADB ZIP file
    Write-Host "Extracting ADB..."
    Expand-Archive -Path $adbZipPath -DestinationPath $adbFolderPath
    $adbDownloadProgressBar.Value = 100
    [System.Windows.Forms.Application]::DoEvents() # Refresh GUI

    # Delete the ADB.zip file after extraction
    Remove-Item -Path $adbZipPath -Force

    # After extraction, close the form and display success message
    $adbDownloadForm.Close()
    [System.Windows.Forms.MessageBox]::Show("ADB has been downloaded and extracted.", "Download Complete", [System.Windows.Forms.MessageBoxButtons]::OK)
}

# Function to check if Pico Theme Manager APK is already downloaded
function Check-PicoThemeManagerExists {
    $toolsFolderPath = Join-Path -Path (Get-Location) -ChildPath "tools"
    $destinationPath = Join-Path -Path $toolsFolderPath -ChildPath "PicoThemeManager.apk"
    
    return (Test-Path $destinationPath)
}

# Function to check if any device is connected
function Check-AnyDevice {
    # Run adb devices command and capture the output
    $deviceOutput = & $adbPath devices

    # Check if there are any devices listed in the adb devices output
    if ($deviceOutput -match "\tdevice$") {
        return $true
    } else {
        return $false
    }
}

# Function to check if Pico Theme Manager is installed
function Check-PicoThemeManagerInstalled {
    # Run the adb shell command to list installed packages
    $packageList = & $adbPath shell pm list packages | findstr "cc.sovellus.picothememanager"

    # If package exists in the list, return true
    if ($packageList) {
        return $true
    } else {
        return $false
    }
}

# Function to install Pico Theme Manager
function Install-PicoThemeManager {
    $toolsFolder = Join-Path -Path (Get-Location) -ChildPath "tools"
    $apkPath = Join-Path -Path $toolsFolder -ChildPath "PicoThemeManager.apk"

    # Check if adb.exe exists
    if (-not (Test-Path $adbPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "adb.exe not found in the ADB folder. Please ensure it exists.",
            "ADB Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }

    # Check if the APK exists
    if (-not (Test-Path $apkPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager is not downloaded.",
            "File Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    # Check if Pico Theme Manager is already installed
    if (Check-PicoThemeManagerInstalled) {
        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager is already installed on the device.",
            "Already Installed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        return
    }

    # Check if any device is connected
    if (-not (Check-AnyDevice)) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Please plug in your Pico Headset.",
            "No Device Found",
            [System.Windows.Forms.MessageBoxButtons]::OKCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        # If user clicked "OK", recheck if any device is connected
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $deviceConnected = $false
            while (-not $deviceConnected) {
                Start-Sleep -Seconds 2  # Wait 2 seconds before checking again
                $deviceConnected = Check-AnyDevice

                if (-not $deviceConnected) {
                    # Keep checking until the device is plugged in
                    $result = [System.Windows.Forms.MessageBox]::Show(
                        "Device still not found. Please plug in your Pico Headset.",
                        "No Device Found",
                        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                    )
                    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
                        return  # Exit if the user cancels
                    }
                }
            }
        }
    }

    # Proceed with installation if the device is connected
    $progressForm = New-Object System.Windows.Forms.Form
    $progressForm.Text = "Installing Pico Theme Manager"
    $progressForm.Size = New-Object System.Drawing.Size(400, 150)

    $progressLabel = New-Object System.Windows.Forms.Label
    $progressLabel.Text = "Installing..."
    $progressLabel.Size = New-Object System.Drawing.Size(300, 20)
    $progressLabel.Location = New-Object System.Drawing.Point(50, 20)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(300, 30)
    $progressBar.Location = New-Object System.Drawing.Point(50, 50)
    $progressBar.Maximum = 2
    $progressBar.Value = 0

    $progressForm.Controls.Add($progressLabel)
    $progressForm.Controls.Add($progressBar)

    # Show the progress form
    $progressForm.Show()

    # Run the first command: adb install
    $progressLabel.Text = "Installing Pico Theme Manager APK..."
    [System.Windows.Forms.Application]::DoEvents()
    $installResult = & $adbPath install -i com.picovr.store "`"$apkPath`""

    if ($installResult -match "Success") {
        $progressBar.Value = 1
        [System.Windows.Forms.Application]::DoEvents()

        # Run the second command: adb shell pm grant
        $progressLabel.Text = "Granting permissions to Pico Theme Manager..."
        $grantResult = & $adbPath shell pm grant cc.sovellus.picothememanager android.permission.WRITE_SECURE_SETTINGS
        $progressBar.Value = 2
        [System.Windows.Forms.Application]::DoEvents()

        $progressForm.Close()

        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager has been installed successfully, and permissions have been granted.",
            "Installation Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        $progressForm.Close()

        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager was not installed due to an error. Please check your device and try again.",
            "Installation Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

# Function to download USB drivers
function Start-USBDownload {
    $usbDriverPath = Join-Path -Path (Get-Location) -ChildPath "usb_driver"

    # Check if the usb_driver folder already exists
    if (Test-Path $usbDriverPath) {
        [System.Windows.Forms.MessageBox]::Show(
            "USB drivers are already downloaded.",
            "Driver Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        GoToMainMenu
        return
    }

    # Create the usb_driver folder if it doesn't exist
    New-Item -ItemType Directory -Path $usbDriverPath

    # Create subfolders for different driver components
    $subFolders = @("i386", "amd64")
    foreach ($subFolder in $subFolders) {
        New-Item -ItemType Directory -Path (Join-Path -Path $usbDriverPath -ChildPath $subFolder)
    }

    $driverUrls = @(
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/source.properties",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/androidwinusba64.cat",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/androidwinusb86.cat",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/android_winusb.inf",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/i386/winusbcoinstaller2.dll",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/i386/WdfCoInstaller01009.dll",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/i386/WUDFUpdate_01009.dll",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/amd64/WUDFUpdate_01009.dll",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/amd64/WdfCoInstaller01009.dll",
        "https://github.com/Dreachu/api.picoenvironmentarchive/raw/refs/heads/main/usb_driver/amd64/winusbcoinstaller2.dll"
    )

    # Create a new form for the "Downloading required files" popup
    $downloadForm = New-Object System.Windows.Forms.Form
    $downloadForm.Text = "Downloading Required Files"
    $downloadForm.Size = New-Object System.Drawing.Size(350, 200)

    $downloadLabel = New-Object System.Windows.Forms.Label
    $downloadLabel.Text = "Downloading USB Drivers..."
    $downloadLabel.Size = New-Object System.Drawing.Size(300, 20)
    $downloadLabel.Location = New-Object System.Drawing.Point(50, 30)

    $downloadProgressBar = New-Object System.Windows.Forms.ProgressBar
    $downloadProgressBar.Size = New-Object System.Drawing.Size(250, 30)
    $downloadProgressBar.Location = New-Object System.Drawing.Point(50, 70)
    $downloadProgressBar.Maximum = $driverUrls.Count
    $downloadProgressBar.Value = 0

    $downloadForm.Controls.Add($downloadLabel)
    $downloadForm.Controls.Add($downloadProgressBar)

    # Show the form
    $downloadForm.Show()

    foreach ($url in $driverUrls) {
        $fileName = [System.IO.Path]::GetFileName($url)
        $destinationPath = $usbDriverPath

        # Check for subfolder placement
        if ($url -like "*i386*") {
            $destinationPath = Join-Path -Path $usbDriverPath -ChildPath "i386"
        } elseif ($url -like "*amd64*") {
            $destinationPath = Join-Path -Path $usbDriverPath -ChildPath "amd64"
        }

        $destinationPath = Join-Path -Path $destinationPath -ChildPath $fileName

        Invoke-WebRequest -Uri $url -OutFile $destinationPath
        $downloadProgressBar.Value++
        [System.Windows.Forms.Application]::DoEvents() # Refresh GUI
    }

    # After downloading all files, close the form and display success message
    $downloadForm.Close()
    [System.Windows.Forms.MessageBox]::Show("Required USB drivers have been downloaded.", "Download Complete", [System.Windows.Forms.MessageBoxButtons]::OK)
}

# Function to install USB drivers using PowerShell
function Install-USBDriver {
    $usbDriverPath = Join-Path -Path (Get-Location) -ChildPath "usb_driver"
    
    # Check if the usb_driver folder exists and contains .inf files
    $driverFiles = Get-ChildItem -Path $usbDriverPath -Recurse -Filter "*.inf"
    
    if ($driverFiles.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "No USB driver files found in the usb_driver folder.",
            "Installation Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }

    # Run pnputil to install the drivers
    foreach ($driverFile in $driverFiles) {
        Write-Host "Installing driver: $($driverFile.Name)"
        
        # Run pnputil to add the driver
        $pnputilCommand = "pnputil /add-driver `"$($driverFile.FullName)`" /install"
        Invoke-Expression $pnputilCommand

        # Check if the driver was installed successfully
        if ($?) {
            Write-Host "Successfully installed: $($driverFile.Name)"
        } else {
            Write-Host "Failed to install: $($driverFile.Name)"
        }
    }

    # Show success message after installation
    [System.Windows.Forms.MessageBox]::Show(
        "USB drivers installed successfully.",
        "Installation Complete",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}

# Function to check if the drivers are installed
function Check-USBDriverInstallation {
    $driverInstalled = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like "*Pico*" }

    if ($driverInstalled) {
        [System.Windows.Forms.MessageBox]::Show(
            "USB driver already installed.",
            "Driver Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        [System.Windows.Forms.MessageBox]::Show(
            "USB driver is not installed. Installing now...",
            "Driver Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        Install-USBDriver
    }

# Check if adb.exe exists in the ADB folder
if (-Not (Test-Path $adbPath)) {
    [System.Windows.Forms.MessageBox]::Show(
        "adb.exe not found in the ADB folder.",
        "Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    return
}

Write-Host "adb.exe is located at: $adbPath"
}

# Define the adb.exe path in the ADB folder
$adbPath = Join-Path -Path (Get-Location) -ChildPath "ADB\adb.exe"

# Function to download environments
function Download-Environments {
    param ($author)

    # Define the environments folder path
    $environmentsFolder = Join-Path -Path (Get-Location) -ChildPath "environments"

    # Check if the environments folder exists, if not, create it
    if (-not (Test-Path $environmentsFolder)) {
        New-Item -ItemType Directory -Path $environmentsFolder
    }

    $url = "https://raw.githubusercontent.com/Dreachu/api.picoenvironmentarchive/refs/heads/main/v1/environments"
    $outputFile = "environments.json"

    # Download the data
    $response = Invoke-WebRequest -Uri $url
    $environments = $response.Content | ConvertFrom-Json

    # Filter by author if specified
    if ($author) {
        $environments = $environments | Where-Object { $_.author -eq $author }
    }

    # Check if environments are already downloaded
    $notDownloadedEnvironments = $environments | Where-Object { -not (Check-EnvironmentExists $_) }

    if ($notDownloadedEnvironments.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "$author environments are already downloaded.",
            "Environment Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        return
    }

    # Update progress bar settings
    $progressBar.Maximum = $notDownloadedEnvironments.Count
    $progressBar.Value = 0
    $progressBar.Visible = $true
    $label.Visible = $true

    # Download the missing environments
    foreach ($index in 0..($notDownloadedEnvironments.Count - 1)) {
        $environment = $notDownloadedEnvironments[$index]
        $fileUrl = $environment.filePath
        $fileName = "$($environment.title).apk"
        $destinationPath = Join-Path -Path $environmentsFolder -ChildPath $fileName

        # Update the label and progress bar
        $label.Text = "Downloading $($environment.title)..."
        $progressBar.Value = $index + 1
        $form.Refresh()  # Refresh the form to update the GUI
        [System.Windows.Forms.Application]::DoEvents()  # Process any pending GUI events

        # Download the APK
        Invoke-WebRequest -Uri $fileUrl -OutFile $destinationPath
        Write-Host "Downloaded: $fileName"

        # Delay to simulate download time (you can remove this for actual downloading)
        Start-Sleep -Seconds 1
    }

    Write-Host "Downloaded $($notDownloadedEnvironments.Count) environments."

    # Show the "Download Complete" message
    [System.Windows.Forms.MessageBox]::Show(
        "$author environments have been downloaded.",
        "Download Complete",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    # Hide the progress bar and label, enable back button
    $progressBar.Visible = $false
    $label.Visible = $false
    $backButton.Visible = $true
}

# Function to go to the main menu
function GoToMainMenu {
    $picoButton.Visible = $false
    $oculusButton.Visible = $false
    $allButton.Visible = $false
    $backButton.Visible = $false
    $installDriverButton.Visible = $true
    $downloadButton.Visible = $true
    $installPicoThemeManagerButton.Visible = $true
    $exitButton.Visible = $true
    $downloadThemeButton.Visible = $true
    $progressBar.Visible = $false
    $label.Visible = $false
}

# Function to go to the environment menu
function GoToEnvironmentMenu {
    $downloadButton.Visible = $false
    $installDriverButton.Visible = $false
    $installPicoThemeManagerButton.Visible = $false
    $exitButton.Visible = $false
    $downloadThemeButton.Visible = $false
    $picoButton.Visible = $true
    $oculusButton.Visible = $true
    $allButton.Visible = $true
    $backButton.Visible = $true
}

# Button events
$installDriverButton.Add_Click({
    Check-USBDriverInstallation
})

$downloadButton.Add_Click({
    GoToEnvironmentMenu
})

$downloadThemeButton.Add_Click({
    if (Check-PicoThemeManagerExists) {
        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager is already downloaded.",
            "Pico Theme Manager Check",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        $toolsFolderPath = Join-Path -Path (Get-Location) -ChildPath "tools"
        if (-not (Test-Path $toolsFolderPath)) {
            New-Item -ItemType Directory -Path $toolsFolderPath
        }

        $themeManagerUrl = "https://github.com/Nyabsi/PicoThemeManager/releases/latest/download/PicoThemeManager.apk"
        $destinationPath = Join-Path -Path $toolsFolderPath -ChildPath "PicoThemeManager.apk"
        Invoke-WebRequest -Uri $themeManagerUrl -OutFile $destinationPath

        [System.Windows.Forms.MessageBox]::Show(
            "Pico Theme Manager has been downloaded.",
            "Download Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
})

$backButton.Add_Click({
    GoToMainMenu
})

$picoButton.Add_Click({
    Download-Environments -author "Pico"
})

$oculusButton.Add_Click({
    Download-Environments -author "Oculus"
})

$allButton.Add_Click({
    Download-Environments -author $null
})

$exitButton.Add_Click({
    $form.Close()
})

# Start the USB download before showing the form (if required)
Start-USBDownload
Start-ADBDownload

# Show the main form
$form.Controls.Add($downloadButton)
$form.Controls.Add($installDriverButton)
$form.Controls.Add($downloadThemeButton)
$form.Controls.Add($installPicoThemeManagerButton)
$form.Controls.Add($exitButton)
$form.Controls.Add($backButton)
$form.Controls.Add($picoButton)
$form.Controls.Add($oculusButton)
$form.Controls.Add($allButton)
$form.Controls.Add($progressBar)
$form.Controls.Add($label)

# Start the application
GoToMainMenu
$form.ShowDialog()
