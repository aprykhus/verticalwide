# verticalwide

## Description
Format-VerticalWide is a custom function for displaying data in vertical columns: down, then over. Basically, the opposite of what Format-Wide does: over, then down.

The built-in PowerShell cmdlet Format-Wide organizes horizontally: over, then down.
Similar to ls --format horizontal.
Format-VerticalWide rearranges the pipeline input and re-outputs to Format-Wide
so that data flows down rather than to the right. Similar to ls command in
UNIX and Microsoft Word columns.

### Format-Wide layout
    Horizontal
    1 | 2 | 3
    4 | 5 | 6
    7 | 8 | 9
### Format-VerticalWide layout
    Vertical
    1 | 4 | 7
    2 | 5 | 8
    3 | 6 | 9

## Usage
Two ways to load Format-VerticalWide into PowerShell

### Module Auto-Loading
(Windows OS) Create folder called VerticalWide under Documents/WindowsPowerShell/Modules (PowerShell) or Documents\PowerShell\Modules (PowerShell Core) and copy VerticalWide.psm1 and VerticalWide.psd1 to that folder.
NOTE: You can see the paths that PowerShell loads modules from in the environment variable PSModulePath by running $env:PSModulePath from the PowerShell console.

*Not supported on PowerShell Core in non-Windows OS

### Single Session
Copy verticalwide.ps1 to local hard drive.

Use the Import-Module cmdlet 
- `Import-Module verticalwide.ps1`

or

Dot source
- `. verticalwide.ps1`

# Examples
`Get-Service | Format-VerticalWide`

![Image](VerticalWide.png)

`Get-Service | Format-VerticalWide -Column 3`

![Image](VerticalWideCol.png)

`Get-Service | Format-VerticalWide -AutoSize`

![Image](VerticalWideAuto.png)