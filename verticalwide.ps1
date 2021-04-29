function Format-Vertical($array)
{
    $cols = 2
    $rows = [math]::Ceiling($array.Length/$cols)

    for ($i=0;$i -lt $rows; $i++)
    {
        #ColumnA
        $array[$i]
        #ColumnB and if/then to handle odd number lengths
        if ($i -ne $rows -or $length % 2 -eq 0) {
            $array[$i+$rows]
        }
    }
}