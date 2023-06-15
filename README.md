# 📄 Unveiling PSDocs: Your Partner in Automated Documentation

Greetings readers! If you are tired of manual and inconsistent documentation in your Infrastructure as Code (IaC) projects, then we have a solution. Today, we are going to explore an excellent open-source project by Microsoft, known as **PSDocs**.

PSDocs is a nifty PowerShell module, capable of churning out beautifully organized, styled, and comprehensive markdown documentation from your IaC objects, all thanks to the magic of PowerShell syntax.

### Why Should You Care About PSDocs?

Imagine maintaining the documentation for a large-scale project with multiple contributors. Keeping everything consistent could quickly turn into an uphill battle. And this is where PSDocs shines! Here are a few compelling reasons why you should embrace PSDocs:

**Consistency**: PSDocs can help you maintain a standardized documentation style across the project, reducing inconsistencies that often creep in with multiple authors.
**Efficiency**: It's no secret that writing and maintaining up-to-date documentation can be time-consuming. PSDocs does the heavy lifting for you, saving you precious time.
**Automated Updates**: With PSDocs, you can ensure your documentation evolves with your code. Every change in the code can be automatically reflected in the docs.
**Integration**: What if your documentation process was a seamless part of your CI/CD pipeline? Well, with PSDocs, you can achieve just that.
PSDocs in Action

Let's delve into a practical example. Suppose we're using Bicep for our IaC and we want to automate the documentation process within our GitHub repository. We can leverage PSDocs in a GitHub Actions workflow to generate individual markdown files for each Bicep module. When this documentation is generated, a pull request is automatically created to update the repository. This keeps the documentation consistently up-to-date with the Bicep modules.

Here's how our GitHub Actions workflow might look:

```yml
# GitHub Actions Workflow
- name: Create ARM Templates from Bicep files
  run: |
    ${{ github.workspace }}/scripts/generate-readme.ps1
  shell: pwsh
- name: Setup Git Config
  run: |
    git config --global user.name "{{ github.actor }}"
    git config --global user.email "{{ github.pusher.email }}"
- name: Create PR
  run: |
    git checkout -b README
    git add --all
    git commit -m "Updating README with latest documentation"
    git push origin README
    gh pr create --title "Updating README with latest documentation" --body "This documentation is automatically generated and should not be updated manually."
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

In this workflow, we run a PowerShell script, generate-readme.ps1, which contains the magic of PSDocs. This script takes care of everything: it converts the Bicep files into ARM templates, generates README files for each module using PSDocs, and finally removes the ARM templates. The workflow then creates a pull request with the newly generated markdown files.

### A Deep dive into the PowerShell Script

Let's now take a closer look at the engine behind our automated documentation process - the PowerShell script, generate-readme.ps1. This script takes our Bicep files, converts them into ARM templates, uses PSDocs to generate README files, and finally removes the ARM templates.

### Powershell script for generating readme

The PowerShell script **(scripts/psdocs.ps1)** performs several actions to create the Bicep documentation. We start with installing necessary PowerShell modules, then it processes Bicep files, generates README files for each module, and finally removes the ARM template files. Here is a step-by-step breakdown of the script:

**Step 1: Istall necessary modules**
The script begins by installing the 'Az' and 'PSDocs.Azure' modules from the PowerShell Gallery (PSGallery) using the **Install-Module cmdlet**. The **-Force** parameter is used to force the installation without any prompts.

```Powershell
Install-Module -Name 'Az' -Repository PSGallery -Force
Install-Module -Name 'PSDocs.Azure' -Repository PSGallery -force;
```

**Step 2: Define variables**
It sets the **\$rootFolderPath** to _/resources_ and **$DocName** to _README_, which will be used later in the script.

```Powershell
$rootFolderPath = 'resources';
$DocName = 'README';
```

**Step 3: Find all Bicep files**
The script then finds all Bicep files (.bicep) in the specified root folder and its subfolders using the **Get-ChildItem** cmdlet. The **-Recurse** parameter allows it to search in subfolders, and the **-File** parameter restricts the results to files only.

```Powershell
$bicepFiles = Get-ChildItem -Path $rootFolderPath -Filter '*.bicep' -Recurse -File
```

**Step 4: Convert Bicep files to ARM templates**

It iterates over each Bicep file and converts it to an ARM template using the **bicep build** command. If there is an error during the conversion, it will catch the error and output it using the **Write-Error** cmdlet.

```Powershell
foreach ($bicepFile in $bicepFiles) {
    $bicepFilePath = $bicepFile.FullName
    $armTemplateFilePath = [System.IO.Path]::ChangeExtension($bicepFilePath, 'json')

    try {
        bicep build $bicepFilePath --outfile $armTemplateFilePath
        Write-Host 'Bicep file ($bicepFilePath) successfully converted to ARM template ($armTemplateFilePath).'
    }
    catch {
        Write-Error 'An error occurred while converting the Bicep file to ARM template: $_'
    }
}
```

**Step 5: Find all module templates**

The script then finds all files named 'main.json' in the root folder and its subfolders, which are the module templates.

```Powershell
$templateFiles = Get-ChildItem -Path $rootFolderPath -Recurse -File | `
    Where-Object { ($_.name -eq 'main.json') } | `
    Get-ChildItem
```

**Step 6: Generate a README for each module**

For each module template, it generates a README file using the **Invoke-PSDocument** cmdlet from the 'PSDocs.Azure' module and saves it to a file using the **Out-File** cmdlet. If a README file already exists, it replaces it with the new content.

```Powershell
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
```

**Step 7: Removes the ARM template**
Finally, the script removes the ARM templates JSON files that were created from the Bicep files. It dows this using the **Remove-Item** command.

```Powershell
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
```

### Wrapping up

In this era of DevOps and IaC, documentation can easily become an afterthought. But with tools like PSDocs, you no longer need to choose between maintaining your infrastructure and keeping your documentation up to date.

PSDocs can take a lot of stress out of your IaC projects by automating your documentation process, keeping it consistent, and always aligned with your latest code. So, why not give it a try?

If you're interested in learning more about how to customize your generated documentation, be sure to stay tuned for my upcoming blog posts.

As always, make sure you check out the official [PSDocs documentation](https://github.com/microsoft/PSDocs)
