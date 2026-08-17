# Wymuś kodowanie UTF-8 dla konsoli
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "             ZAWANSOWANY MENEDZER SIECIOWY                      " -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host "Wybierz opcje z menu, aby uruchomic wybrane narzedzie:" -ForegroundColor White
    Write-Host ""
    
    Write-Host " [1] " -ForegroundColor Green -NoNewline
    Write-Host "Aktywne polaczenia sieciowe (Aplikacje)" -ForegroundColor White
    Write-Host "     -> Wyswietla podsumowanie programow laczacych sie z siecia." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host " [2] " -ForegroundColor Green -NoNewline
    Write-Host "Szczegolowa lista polaczen IP i Portow" -ForegroundColor White
    Write-Host "     -> Pokazuje adresy IP, porty oraz dokladne sciezki .exe." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host " [3] " -ForegroundColor Green -NoNewline
    Write-Host "Podglad zasobow w czasie rzeczywistym (Resmon)" -ForegroundColor White
    Write-Host "     -> Otwiera systemowy Monitor Zasobow z wykresem sieci." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host " [4] " -ForegroundColor Green -NoNewline
    Write-Host "Pelny raport Netstat (Wymaga Administratora)" -ForegroundColor White
    Write-Host "     -> Klasyczne podgladanie otwartych gniazd i polaczen." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host " [5] " -ForegroundColor Green -NoNewline
    Write-Host "Ciagly monitoring polaczen (Live Auto-Refresh)" -ForegroundColor White
    Write-Host "     -> Odswieza liste polaczen co 3 sekundy." -ForegroundColor DarkGray
    Write-Host ""

    Write-Host " [Q] " -ForegroundColor Red -NoNewline
    Write-Host "Wyjscie z programu" -ForegroundColor White
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Launch-InNewWindow {
    param(
        [string]$Title,
        [string]$ScriptBlockText
    )

    $fullScript = @"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
`$host.UI.RawUI.WindowTitle = '$Title'
$ScriptBlockText
Write-Host ''
Write-Host 'Nacisnij dowolny klawisz, aby zamknac to okno...' -ForegroundColor Yellow
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($fullScript))
    Start-Process powershell.exe -ArgumentList "-NoExit", "-EncodedCommand", $encodedCommand
}

# Glowna petla programu
do {
    Show-Menu
    $choice = Read-Host "Wpisz numer opcji i nacisnij Enter"

    switch ($choice) {
        '1' {
            $cmd = @'
Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
    Group-Object OwningProcess | 
    Select-Object @{
        Name="Nazwa Procesu"; 
        Expression={
            $proc = Get-Process -Id $_.Name -ErrorAction SilentlyContinue
            if ($proc -and $proc.ProcessName) { $proc.ProcessName } else { "System/Inne" }
        }
    }, @{Name="PID"; Expression={$_.Name}}, Count | 
    Sort-Object Count -Descending | 
    Format-Table -AutoSize
'@
            Launch-InNewWindow -Title "Liczba polaczen wg procesow" -ScriptBlockText $cmd
        }

        '2' {
            $cmd = @'
Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, 
                  @{Name="Proces"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}},
                  @{Name="Sciezka"; Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Path}} | 
    Out-GridView -Title "Aktywne polaczenia IP/Porty"
'@
            Launch-InNewWindow -Title "Szczegoly Polaczen IP" -ScriptBlockText $cmd
        }

        '3' {
            Start-Process "resmon.exe"
        }

        '4' {
            $cmd = "netstat -abno"
            Launch-InNewWindow -Title "Netstat - Pelny Raport" -ScriptBlockText $cmd
        }

        '5' {
            $cmd = @'
while($true) {
    Clear-Host
    Write-Host "=== MONITORING POLACZEN W CZASIE RZECZYWISTYM (Ctrl+C aby zakonczyc) ===" -ForegroundColor Cyan
    Write-Host "Ostatnia aktualizacja: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    
    Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
        Group-Object OwningProcess | 
        Select-Object @{
            Name="Nazwa Procesu"; 
            Expression={
                $proc = Get-Process -Id $_.Name -ErrorAction SilentlyContinue
                if ($proc -and $proc.ProcessName) { $proc.ProcessName } else { "System/Inne" }
            }
        }, Count | 
        Sort-Object Count -Descending | 
        Format-Table -AutoSize

    Start-Sleep -Seconds 3
}
'@
            Launch-InNewWindow -Title "Monitoring Live" -ScriptBlockText $cmd
        }

        'q' {
            Write-Host "Zamykanie..." -ForegroundColor Yellow
        }

        Default {
            Write-Host "Nieprawidlowy wybor. Nacisnij Enter, aby sprobowac ponownie." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne 'q')