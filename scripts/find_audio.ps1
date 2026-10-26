$res = Invoke-RestMethod -Uri "https://api.github.com/repos/extratone/iOSSystemSounds/git/trees/main?recursive=1" -Headers @{ "User-Agent" = "PowerShell" }
$matching = $res.tree | Where-Object { $_.path -match 'focus|navigation|click' }
$matching | ForEach-Object { Write-Host $_.path }
