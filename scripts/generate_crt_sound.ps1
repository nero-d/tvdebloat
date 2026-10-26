$sampleRate = 44100
$duration = 0.45
$totalSamples = [int]($sampleRate * $duration)
$data = New-Object byte[] ($totalSamples * 2)

for ($i = 0; $i -lt $totalSamples; $i++) {
    $t = $i / $sampleRate
    $sample = 0.0

    # 1. Flyback whine sweeping down from 8000Hz to 120Hz
    if ($t -lt 0.20) {
        $freq = 8000.0 * [Math]::Pow(0.015, $t / 0.20)
        $whine = [Math]::Sin(2.0 * [Math]::PI * $freq * $t) * [Math]::Exp(-$t * 16.0) * 0.45
        $sample += $whine
    }

    # 2. CRT high-voltage electrical snap / relay click at t=0.17s
    if ($t -ge 0.16 -and $t -le 0.22) {
        $dt = ($t - 0.16) / 0.06
        $snap = [Math]::Sin(2.0 * [Math]::PI * 920.0 * ($t - 0.16)) * [Math]::Exp(-$dt * 22.0) * 0.75
        $sample += $snap
    }

    # 3. Soft deep magnetic coil decay (65Hz dying out)
    if ($t -ge 0.17) {
        $dt = $t - 0.17
        $thump = [Math]::Sin(2.0 * [Math]::PI * 65.0 * $dt) * [Math]::Exp(-$dt * 16.0) * 0.35
        $sample += $thump
    }

    # Clamp to [-1.0, 1.0]
    if ($sample -gt 1.0) { $sample = 1.0 }
    if ($sample -lt -1.0) { $sample = -1.0 }

    $intSample = [int16]($sample * 32767.0)
    $bytes = [BitConverter]::GetBytes($intSample)
    $data[$i * 2] = $bytes[0]
    $data[$i * 2 + 1] = $bytes[1]
}

# Write standard WAV header (44 bytes)
$stream = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($stream)

$writer.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
$writer.Write([int32]($totalSamples * 2 + 36))
$writer.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
$writer.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
$writer.Write([int32]16)
$writer.Write([int16]1)
$writer.Write([int16]1)
$writer.Write([int32]$sampleRate)
$writer.Write([int32]($sampleRate * 2))
$writer.Write([int16]2)
$writer.Write([int16]16)
$writer.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
$writer.Write([int32]($totalSamples * 2))
$writer.Write($data)

[System.IO.File]::WriteAllBytes('C:\Users\sanik\tv_debloat\launcher\res\raw\sound_crt_off.wav', $stream.ToArray())
$writer.Close()
$stream.Close()
Write-Host "Generated sound_crt_off.wav: " (Get-Item 'C:\Users\sanik\tv_debloat\launcher\res\raw\sound_crt_off.wav').Length "bytes"
