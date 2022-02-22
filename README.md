# verticalwide

## Description
Format-VerticalWide is a custom function for displaying data in vertical columns, down and over. Basically the opposite of what Format-Wide does.

The built-in PowerShell cmdlet Format-Wide organizes horizontally, over and down.
Similar to ls --format horizontal.
Format-VerticalWide rearranges the pipeline input and re-outputs to Format-Wide
so that data flows down rather than to the right. Similar to ls command in
POSIX and Microsoft Word columns.

## Usage
Two ways to load Format-VerticalWide into PowerShell

### Module Auto-Loading
Copy VerticalWide.psm1 and VerticalWide.psd1 files to user modules folder (Windows) Documents/WindowsPowerShell/Modules/VerticalWide

*not supported on PowerShell Core on POSIX (Linux)

### Single Session
Use the Import-Module cmdlet 
- `import-module verticalwide.ps1`

or

Dot source
- `. verticalwide.ps1`

# Screenshot
![Image](VerticalWide.png)