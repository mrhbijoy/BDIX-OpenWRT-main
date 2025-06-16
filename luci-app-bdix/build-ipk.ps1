# PowerShell script to create IPK package for OpenWRT
# Run this script in the luci-app-bdix directory

Write-Host "Building BDIX LuCI IPK Package..." -ForegroundColor Green

# Set package name and version
$packageName = "luci-app-bdix"
$version = "1.0.0-1"
$architecture = "all"

# Create temporary build directory
$buildDir = "build-$packageName"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

Write-Host "Created build directory: $buildDir" -ForegroundColor Yellow

# Copy CONTROL files
$controlDir = Join-Path $buildDir "CONTROL"
New-Item -ItemType Directory -Path $controlDir | Out-Null
Copy-Item "CONTROL\*" $controlDir

Write-Host "Copied CONTROL files" -ForegroundColor Yellow

# Copy data files
$dataDir = Join-Path $buildDir "data"
New-Item -ItemType Directory -Path $dataDir | Out-Null

# Create directory structure
$directories = @(
    "usr\lib\lua\luci\controller",
    "usr\lib\lua\luci\model\cbi", 
    "usr\lib\lua\luci\view\bdix",
    "etc\init.d",
    "etc\config"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $dataDir $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
}

# Copy files to proper locations
Copy-Item "data\usr\lib\lua\luci\controller\bdix.lua" (Join-Path $dataDir "usr\lib\lua\luci\controller\")
Copy-Item "data\usr\lib\lua\luci\model\cbi\bdix.lua" (Join-Path $dataDir "usr\lib\lua\luci\model\cbi\")
Copy-Item "data\usr\lib\lua\luci\view\bdix\status.htm" (Join-Path $dataDir "usr\lib\lua\luci\view\bdix\")
Copy-Item "data\etc\init.d\bdix" (Join-Path $dataDir "etc\init.d\")
Copy-Item "data\etc\config\bdix" (Join-Path $dataDir "etc\config\")

Write-Host "Copied data files" -ForegroundColor Yellow

# Set permissions for CONTROL scripts
if (Get-Command "wsl" -ErrorAction SilentlyContinue) {
    Write-Host "Setting file permissions using WSL..." -ForegroundColor Yellow
    wsl chmod +x "$buildDir/CONTROL/postinst"
    wsl chmod +x "$buildDir/CONTROL/prerm" 
    wsl chmod +x "$buildDir/CONTROL/postrm"
    wsl chmod +x "$buildDir/data/etc/init.d/bdix"
}

# Calculate installed size
$dataSize = (Get-ChildItem -Recurse $dataDir | Measure-Object -Property Length -Sum).Sum
$installedSize = [math]::Round($dataSize / 1024)

# Update control file with calculated size
$controlFile = Join-Path $controlDir "control"
$controlContent = Get-Content $controlFile
$controlContent = $controlContent -replace "Installed-Size: \d+", "Installed-Size: $installedSize"
$controlContent | Set-Content $controlFile

Write-Host "Updated installed size: $installedSize KB" -ForegroundColor Yellow

# Create debian-binary file
"2.0" | Set-Content (Join-Path $buildDir "debian-binary")

# Create tar archives
Write-Host "Creating tar archives..." -ForegroundColor Yellow

if (Get-Command "wsl" -ErrorAction SilentlyContinue) {
    # Use WSL tar if available
    $currentDir = Get-Location
    Set-Location $buildDir
    
    wsl tar -czf "control.tar.gz" -C "CONTROL" .
    wsl tar -czf "data.tar.gz" -C "data" .
    
    # Create the IPK file
    wsl ar rcs "../$packageName`_$version`_$architecture.ipk" "debian-binary" "control.tar.gz" "data.tar.gz"
    
    Set-Location $currentDir
} else {
    Write-Host "WSL not available. Creating ZIP file instead..." -ForegroundColor Yellow
    
    # Create control.tar.gz equivalent
    Compress-Archive -Path (Join-Path $buildDir "CONTROL\*") -DestinationPath (Join-Path $buildDir "control.zip") -Force
    
    # Create data.tar.gz equivalent  
    Compress-Archive -Path (Join-Path $buildDir "data\*") -DestinationPath (Join-Path $buildDir "data.zip") -Force
    
    # Create final package as ZIP (can be manually converted to IPK)
    $packageFiles = @(
        Join-Path $buildDir "debian-binary"
        Join-Path $buildDir "control.zip" 
        Join-Path $buildDir "data.zip"
    )
    
    Compress-Archive -Path $packageFiles -DestinationPath "$packageName`_$version`_$architecture.zip" -Force
    
    Write-Host "Created $packageName`_$version`_$architecture.zip" -ForegroundColor Green
    Write-Host "Note: You may need to rename .zip to .ipk and ensure proper tar.gz format for OpenWRT" -ForegroundColor Yellow
}

# Cleanup
Remove-Item -Recurse -Force $buildDir

if (Test-Path "$packageName`_$version`_$architecture.ipk") {
    Write-Host "✅ IPK package created successfully: $packageName`_$version`_$architecture.ipk" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Installation Instructions:" -ForegroundColor Cyan
    Write-Host "1. Upload the IPK file via: System → Software → Upload Package" -ForegroundColor White
    Write-Host "2. Or use command: opkg install $packageName`_$version`_$architecture.ipk" -ForegroundColor White
    Write-Host "3. Access via: Services → BDIX Proxy" -ForegroundColor White
} else {
    Write-Host "✅ Package files created. Check the ZIP file and convert to IPK if needed." -ForegroundColor Green
}

Write-Host ""
Write-Host "Package build completed!" -ForegroundColor Green
