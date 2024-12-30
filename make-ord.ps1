$curpath  = (Get-Location).Path
$bytes = [System.IO.File]::ReadAllBytes($curpath + '\' + "desolate.bin")
$list = New-Object 'System.Collections.Generic.List[Byte]'
$list.AddRange($bytes)

# Align to 16 bytes
#Write-Host $bytes.Length
while (($list.Count % 16) -ne 0){
	$list.Add(0)
}
#Write-Host $list.Count

# Prepare the header
$list2 = New-Object 'System.Collections.Generic.List[Byte]'
$list2.AddRange( [system.Text.Encoding]::ASCII.GetBytes("DESOLAT$") )
$list2.Add(0)
$list2.Add(1) # $100 = адрес загрузкиs
$size = $list.Count
$list2.Add($size % 256)
$list2.Add([Math]::Truncate($size / 256))
$list2.Add(0) # атрибуты
$list2.Add(255)
$list2.Add(255)
$list2.Add(255)
$list2.AddRange($list)

$bytes2 = $list2.ToArray()
[System.IO.File]::WriteAllBytes($curpath + '\' + "DESOLAT$.ORD", $bytes2)