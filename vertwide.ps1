function Format-Vertical($length)
{
    $cols = 2
    $rows = [math]::Ceiling($length/$cols)

    for ($i=0;$i -lt $rows; $i++)
    {
        $i
        if ($i -ne $rows -or $length % 2 -eq 0) {
            $i+$rows
        }
    }
}