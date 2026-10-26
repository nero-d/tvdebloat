$bytes = [System.IO.File]::ReadAllBytes("C:\Users\sanik\tv_debloat\backup\libinput.so")

# Search KEYCODES table around offset 153832
for ($off = 150000; $off -le 165000; $off += 8) {
    $ptr = [BitConverter]::ToUInt32($bytes, $off)
    $val = [BitConverter]::ToInt32($bytes, $off + 4)
    if ($ptr -gt 0 -and $ptr -lt $bytes.Length) {
        $end = $ptr
        while ($end -lt $bytes.Length -and $bytes[$end] -ne 0) { $end++ }
        if (($end - $ptr) -gt 2 -and ($end - $ptr) -lt 35) {
            $name = [System.Text.Encoding]::ASCII.GetString($bytes, $ptr, $end - $ptr)
            if ($name -match '^[A-Z0-9_]+$') {
                if ($name -match 'SET|MENU|DASH|QUICK|OPTION|PANEL') {
                    Write-Host ("KeyCode: {0,-25} Value: {1,6} (0x{1:x})" -f $name, $val)
                }
            }
        }
    }
}
