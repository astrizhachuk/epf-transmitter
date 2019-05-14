$action = $args[0]

if ($action -ne "stop") {
    $postgresql = @(docker ps -a -f "name=postgresql-pro-1c" --format "{{.Names}}")

    if ($postgresql.Length -eq 0) {
        docker run --name postgresql-pro-1c -d -p 5432:5432 -v postgresql-pro-1c-data:/var/lib/postgresql strizhhh/postgresql-pro-1c:9.6
    } else {
        docker restart postgresql-pro-1c
    }
    
    Get-Process | Where-Object {$_.ProcessName -Eq "httpd"} | Stop-Process
    Start-Process -NoNewWindow "C:\Apache2\bin\httpd.exe"
    Get-Process | Where-Object {$_.ProcessName -Eq "rmngr"} | Stop-Process
    Start-Process -NoNewWindow "C:\Program Files\1cv8\8.3.10.2667\bin\ragent.exe" "-debug -http"
} else {
    Get-Process | Where-Object {$_.ProcessName -Eq "httpd"} | Stop-Process
    Get-Process | Where-Object {$_.ProcessName -Eq "rmngr"} | Stop-Process
    Get-Process | Where-Object {$_.ProcessName -Eq "ragent"} | Stop-Process
    Get-Process | Where-Object {$_.ProcessName -Eq "rphost"} | Stop-Process
    Get-Process | Where-Object {$_.ProcessName -Eq "dbgs"} | Stop-Process
    docker stop postgresql-pro-1c
}
