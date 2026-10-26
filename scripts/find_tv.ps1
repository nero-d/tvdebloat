$tasks = @()
$found = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

1..254 | ForEach-Object {
    $ip = "192.168.1.$_"
    $tasks += [System.Threading.Tasks.Task]::Run([Action]{
        $client = New-Object System.Net.Sockets.TcpClient
        try {
            $iar = $client.BeginConnect($ip, 5555, $null, $null)
            if ($iar.AsyncWaitHandle.WaitOne(300, $false)) {
                $client.EndConnect($iar)
                $found.Add($ip)
            }
        } catch {
        } finally {
            $client.Close()
        }
    })
}

[System.Threading.Tasks.Task]::WaitAll($tasks)
foreach ($ip in $found) {
    Write-Host "FOUND ADB ON $ip" -ForegroundColor Green
}
if ($found.Count -eq 0) {
    Write-Host "No device found on port 5555" -ForegroundColor Yellow
}
