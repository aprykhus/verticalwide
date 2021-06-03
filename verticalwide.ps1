function Format-Vertical {
    Param(
    $Column = 2,
    [string[]]$Properties = "Name",
    [Switch]$AutoSize)

    $array = @($input)
    $count = $array.Count

    <# Convert input object to PSCustomObject to write
     nulls so I can properly output blank cells #>

    #Build a ScriptBlock with variable number of properties like this:
    #'$array | ForEach-Object -Process {[PSCustomObject] @{$($Properties[0])=$_.$($Properties[0]);$($Properties[1])=$_.$($Properties[1])}}'

    $MainBlock = '$array | ForEach-Object -Process {[PSCustomObject]'

    $ProcessBlock = '@{'
    foreach ($n in 0..($Properties.Count-1)) {
        $ProcessBlock += '$($Properties[' + $n + '])=[string]$_.$($Properties[' + $n + ']);'
    }

    $ProcessBlock += '}}'

    $ScriptBlock = $MainBlock + $ProcessBlock

    $block = [ScriptBlock]::Create($ScriptBlock)
    $array = Invoke-Command $block

    # Get column widths based off the longest string in each column/property
    # Store each column width in array
    $colwidths = @()
    foreach ($n in 0..($Properties.Count-1)) {
        $proplengths = @()
        foreach ($a in $array) {
            if ($a -eq $null) {
                $proplengths += 0
            } else {
                $proplengths += $a.$($Properties[$n]).Length #Check for null
            }
        }
        $maxlength = $proplengths | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        $colwidths += $maxlength
    }

    #AutoSize
    #Total max lengths of each property
    $coltotal = $colwidths | Measure-Object -sum | Select-Object -ExpandProperty Sum
    #Add double the count of elements to account for space in between sub-columns
    $coltotal += ($colwidths | Measure-Object | Select-Object -ExpandProperty Count)*2
    #Get char width of current console window
    $consolewidth = $host.UI.RawUI.WindowSize.Width
    #divide console width by total major column width
    $autocols = [Math]::Floor($consolewidth/$coltotal)

    if ($AutoSize) {
        $cols = $autocols
    } else {
        $cols = $Column
    }

    $rows = [math]::Ceiling($count/$cols) #round up

    $reordered = @() #initialize array

    <# Rearrange array to output vertically versus horizontally
    Horizontal
     1 | 2 | 3
     4 | 5 | 6
     7 | 8 | 9
    Vertical
     1 | 4 | 7
     2 | 5 | 8
     3 | 6 | 9
     #>
    for ($i = 0; $i -lt $rows; $i++) {
        for ($j = 0; $j -lt $count; $j += $rows) {
            if ($i+$j -ge $count) {
                #Blank cells for remainder of space on last column, lower right corner
                $reordered += [PSCustomObject]@{Names = $null}
            } else {
                $reordered += $array[$i+$j]
            }
        }
    }

    #Build ScriptBlock for variable amount of properties to pass to Format-Wide cmdlet
    if ($AutoSize) {
        $MainBlock = '$reordered | Format-Wide -Column $autocols -Property '
    } else {
        $MainBlock = '$reordered | Format-Wide -Column $cols -Property '
    }

    $ProcessBlock = '@{e={"'
    foreach ($n in 0..($Properties.Count-1)) {
        $ProcessBlock += '{' + $n + '} '
    }

    $ProcessBlock += '" -f '

    foreach ($n in 0..($Properties.Count-1)) {
        if ($n -ne $Properties.Count-1) {
            $ProcessBlock += '$_.$($Properties[' + $n + ']).ToString().PadRight($($colwidths[' + $n + ']),[char]32), ' #TODO: Check for Null?
        } else {
            $ProcessBlock += '$_.$($Properties[' + $n + '])}}'
        }
    }

    $ScriptBlock = $MainBlock + $ProcessBlock

    $block = [ScriptBlock]::Create($ScriptBlock)

    Write-Debug $ScriptBlock

    #Resulting script block should look like this:
    #$reordered | Format-Wide -Column $cols -Property @{e={"{0} {1}" -f $_.$($Properties[0]), $_.$($Properties[1])}}
    Invoke-Command -ScriptBlock $block

    <#
    .Synopsis
    Custom function for displaying data in vertical columns
    .DESCRIPTION
    Format-Wide organizes horizontally, similar to ls --format horizontal.
    Format-vertical rearranges the pipeline input and re-outputs to Format-Wide
    so that data flows down rather than to the right. Similar to ls command in
    POSIX and Microsoft Word columns.

    Format-Wide layout:
        Horizontal
        1 | 2 | 3
        4 | 5 | 6
        7 | 8 | 9
    Format-Vertical layout
        Vertical
        1 | 4 | 7
        2 | 5 | 8
        3 | 6 | 9
    .EXAMPLE
    Get-Process | Format-Vertical


    ApplicationFrameHost                                        svchost
    AppVShNotify                                                svchost
    armsvc                                                      svchost
    audiodg                                                     svchost
    Calculator                                                  svchost
    conhost                                                     svchost
    conhost                                                     svchost
    csrss                                                       svchost
    csrss                                                       svchost
    ctfmon                                                      svchost
    dasHost                                                     svchost
    dllhost                                                     svchost
    dllhost                                                     svchost
    ...

    .EXAMPLE
    Get-Process | Format-Vertical -Column 3


    ApplicationFrameHost                    powershell_ise                          svchost
    AppVShNotify                            Registry                                svchost
    armsvc                                  RuntimeBroker                           svchost
    audiodg                                 RuntimeBroker                           svchost
    Calculator                              RuntimeBroker                           svchost
    conhost                                 RuntimeBroker                           svchost
    conhost                                 RuntimeBroker                           svchost
    csrss                                   RuntimeBroker                           svchost
    csrss                                   RuntimeBroker                           svchost
    ctfmon                                  RuntimeBroker                           svchost
    dasHost                                 RuntimeBroker                           svchost
    dllhost                                 SearchApp                               svchost
    dllhost                                 SearchIndexer                           svchost
    dllhost                                 Secure System                           svchost
    ...


    .EXAMPLE
    Get-Process | Format-Vertical -Column 3 -Properties Id,Name


    7988  ApplicationFrameHost              12700 RuntimeBroker                     3252  svchost
    8916  AppVShNotify                      14300 RuntimeBroker                     3572  svchost
    4332  armsvc                            14436 RuntimeBroker                     3636  svchost
    7652  audiodg                           15248 RuntimeBroker                     3644  svchost
    2808  Calculator                        10104 SearchApp                         3784  svchost
    9296  conhost                           9864  SearchIndexer                     3832  svchost
    13352 conhost                           72    Secure System                     3840  svchost
    696   csrss                             3524  SecurityHealthService             3924  svchost
    13884 csrss                             4660  SecurityHealthSystray             3968  svchost
    5812  ctfmon                            440   services                          4120  svchost
    2356  dasHost                           9464  SettingSyncHost                   4232  svchost
    1288  dllhost                           9896  SgrmBroker                        4240  svchost
    8584  dllhost                           428   ShellExperienceHost               4248  svchost
    14624 dllhost                           12272 sihost                            4256  svchost
    ...
    #>
}