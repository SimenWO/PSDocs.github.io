# Install neccessary modules
Install-Module -Name 'Az' -Repository PSGallery -Force
Install-Module -Name 'PSDocs.Azure' -Repository PSGallery -force;

$rootFolderPath = 'infrastructure';
$DocName = 'README';

# Find all Bicep files in the specified root folder and its subfolders
$bicepFiles = Get-ChildItem -Path $rootFolderPath -Filter '*.bicep' -Recurse -File

# Process each Bicep file
foreach ($bicepFile in $bicepFiles) {
    $bicepFilePath = $bicepFile.FullName
    $armTemplateFilePath = [System.IO.Path]::ChangeExtension($bicepFilePath, 'json')

    # Convert Bicep file to ARM template
    try {
        bicep build $bicepFilePath --outfile $armTemplateFilePath
        Write-Host 'Bicep file ($bicepFilePath) successfully converted to ARM template ($armTemplateFilePath).'
    }
    catch {
        Write-Error 'An error occurred while converting the Bicep file to ARM template: $_'
    }
}

# Find all module templates
$templateFiles = Get-ChildItem -Path $rootFolderPath -Recurse -File | `
    Where-Object { ($_.name -eq 'main.json') } | `
    Get-ChildItem

# Generate a README for each module
foreach ($templateFile in $templateFiles) {
    $templateDir = $templateFile.Directory
    $readmePath = Join-Path -Path $templateDir.FullName -ChildPath "$DocName.md"

    # Generate README and save it to a file
    $output = Invoke-PSDocument -Module PSDocs.Azure -InputObject $templateFile.FullName -InstanceName $DocName -Culture 'en-US'
    $output | Out-File -FilePath $readmePath -Encoding utf8 -Force

    # Check if README.md already exists, and replace it if it does
    $readmeExists = Test-Path "$($templateDir.FullName)\$DocName.md"

    if ($readmeExists) {
        $readmeContent = Get-Content $readmePath -Raw
        Set-Content -Path "$($templateDir.FullName)\$DocName.md" -Value $readmeContent -Force
        Write-Host "README.md file for $($templateDir.Name) module already exists. Overwriting..."
    }
}

foreach ($bicepFile in $bicepFiles) {
    $bicepFilePath = $bicepFile.FullName
    $armTemplateFilePath = [System.IO.Path]::ChangeExtension($bicepFilePath, 'json')
    
    # Remove the ARM template (main.json) file
    try {
        Remove-Item -Path $armTemplateFilePath -Force
        Write-Host "ARM template ($armTemplateFilePath) removed successfully."
    }
    catch {
        Write-Error "An error occurred while removing the ARM template ($armTemplateFilePath): $_"
    }
}