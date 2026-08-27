$ErrorActionPreference = "Stop"

$portableJdk = Join-Path $env:USERPROFILE ".local\dev-tools\jdk-21"
$portableMvn = Join-Path $env:USERPROFILE ".local\dev-tools\apache-maven-3.9.9\bin\mvn.cmd"

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME "bin\java.exe"))) {
    if (Test-Path (Join-Path $portableJdk "bin\java.exe")) {
        $env:JAVA_HOME = $portableJdk
    } else {
        Write-Error "JDK 17+ 가 필요합니다. JAVA_HOME을 설정하거나 $portableJdk 에 JDK 21을 설치하세요."
    }
}

$mvn = "mvn"
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    if (Test-Path $portableMvn) {
        $mvn = $portableMvn
    } else {
        Write-Error "Maven이 PATH에 없습니다. $portableMvn 을 확인하세요."
    }
}

$env:PATH = "$($env:JAVA_HOME)\bin;" + $env:PATH
Set-Location $PSScriptRoot

Write-Host "Java : $env:JAVA_HOME"
Write-Host "앱 주소: http://localhost:8081"
& $mvn jetty:run
