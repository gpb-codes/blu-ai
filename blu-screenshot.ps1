# blu-screenshot.ps1 — captura la pantalla primaria a un PNG, reescalado para ahorrar tokens
# Uso: powershell -File blu-screenshot.ps1 [ruta_salida] [ancho_objetivo]
# Devuelve: ruta imgWximgH realWxrealH scale=S
#   - imgWximgH: tamano de la imagen (reescalada) que vas a MIRAR con Read
#   - realWxrealH: resolucion real de la pantalla
#   - scale=S: factor para convertir coords de la imagen a pixeles reales (pasalo a blu-mouse.ps1)

param(
  [string]$OutPath = "$env:TEMP\blu-screen.png",
  [int]$TargetWidth = 1280
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$realW = $bounds.Width
$realH = $bounds.Height

# Captura a resolucion real
$full = New-Object System.Drawing.Bitmap($realW, $realH)
$g    = [System.Drawing.Graphics]::FromImage($full)
$g.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$g.Dispose()

# Reescala si la pantalla es mas ancha que el objetivo
if ($realW -gt $TargetWidth) {
  $scale = $realW / $TargetWidth
  $imgW  = $TargetWidth
  $imgH  = [int]($realH / $scale)
  $small = New-Object System.Drawing.Bitmap($imgW, $imgH)
  $g2 = [System.Drawing.Graphics]::FromImage($small)
  $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g2.DrawImage($full, 0, 0, $imgW, $imgH)
  $g2.Dispose()
  $small.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $small.Dispose()
  $full.Dispose()
} else {
  $scale = 1
  $imgW = $realW; $imgH = $realH
  $full.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $full.Dispose()
}

$scaleStr = [math]::Round($scale, 4)
Write-Output "$OutPath ${imgW}x${imgH} real=${realW}x${realH} scale=$scaleStr"
