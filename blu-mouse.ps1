# blu-mouse.ps1 — controla mouse y teclado
# Las coords X,Y son las que VES en la imagen; el -Scale (que da blu-screenshot) las
# convierte a pixeles reales. Ej: si la imagen es 1280 ancho y la pantalla 1920, scale=1.5
# Uso:
#   powershell -File blu-mouse.ps1 click 500 300 -Scale 1.5
#   powershell -File blu-mouse.ps1 doubleclick 500 300 -Scale 1.5
#   powershell -File blu-mouse.ps1 rightclick 500 300 -Scale 1.5
#   powershell -File blu-mouse.ps1 move 500 300 -Scale 1.5
#   powershell -File blu-mouse.ps1 type "texto a escribir"
#   powershell -File blu-mouse.ps1 key "{ENTER}"      (teclas: {ENTER} {TAB} {ESC} ^c=Ctrl+C etc.)
#   powershell -File blu-mouse.ps1 scroll 500 300 -Amount -3 -Scale 1.5

param(
  [Parameter(Mandatory=$true)][string]$Action,
  [int]$X, [int]$Y, [string]$Text, [int]$Amount = -3, [double]$Scale = 1.0
)

# Convierte coords de imagen -> pixeles reales
$X = [int]([math]::Round($X * $Scale))
$Y = [int]([math]::Round($Y * $Scale))

Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class BluMouse {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, int extra);
  public const uint LEFTDOWN = 0x0002, LEFTUP = 0x0004;
  public const uint RIGHTDOWN = 0x0008, RIGHTUP = 0x0010;
  public const uint WHEEL = 0x0800;
}
"@

function Move-To($px, $py) { [BluMouse]::SetCursorPos($px, $py) | Out-Null }
function Left-Click { [BluMouse]::mouse_event([BluMouse]::LEFTDOWN,0,0,0,0); Start-Sleep -Milliseconds 30; [BluMouse]::mouse_event([BluMouse]::LEFTUP,0,0,0,0) }
function Right-Click { [BluMouse]::mouse_event([BluMouse]::RIGHTDOWN,0,0,0,0); Start-Sleep -Milliseconds 30; [BluMouse]::mouse_event([BluMouse]::RIGHTUP,0,0,0,0) }

switch ($Action.ToLower()) {
  "move"        { Move-To $X $Y; Write-Output "movido a $X,$Y" }
  "click"       { Move-To $X $Y; Start-Sleep -Milliseconds 60; Left-Click; Write-Output "click en $X,$Y" }
  "doubleclick" { Move-To $X $Y; Start-Sleep -Milliseconds 60; Left-Click; Start-Sleep -Milliseconds 80; Left-Click; Write-Output "doble click en $X,$Y" }
  "rightclick"  { Move-To $X $Y; Start-Sleep -Milliseconds 60; Right-Click; Write-Output "click derecho en $X,$Y" }
  "type"        { [System.Windows.Forms.SendKeys]::SendWait($Text); Write-Output "escrito: $Text" }
  "key"         { [System.Windows.Forms.SendKeys]::SendWait($Text); Write-Output "tecla: $Text" }
  "scroll"      { Move-To $X $Y; Start-Sleep -Milliseconds 60; [BluMouse]::mouse_event([BluMouse]::WHEEL,0,0,[uint32]($Amount*120),0); Write-Output "scroll $Amount en $X,$Y" }
  default       { Write-Output "accion desconocida: $Action" }
}
