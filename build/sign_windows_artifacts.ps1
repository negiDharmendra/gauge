# Copyright 2015 ThoughtWorks, Inc.

# This file is part of Gauge.

# Gauge is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Gauge is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Gauge.  If not, see <http://www.gnu.org/licenses/>.

param (
    [switch]$nightly = $false
)

Push-Location "$pwd\bin\windows_amd64"
signtool sign /debug /v /tr http://timestamp.digicert.com /a /fd sha256 /td sha256 /f $env:CERT_FILE /as gauge.exe
if ($LastExitCode -ne 0) {
     throw "gauge.exe signing failed"
}
Pop-Location

Push-Location "$pwd\bin\windows_386"
signtool sign /debug /v /tr http://timestamp.digicert.com /a /fd sha256 /td sha256 /f $env:CERT_FILE /as gauge.exe
if ($LastExitCode -ne 0) {
     throw "gauge.exe signing failed"
}
Pop-Location

$nightlyFlag = If ($nightly) {"--nightly"} Else {""}
& go run build/make.go --distro  --bin-dir bin\windows_amd64 $nightlyFlag
& go run build/make.go --distro  --bin-dir bin\windows_386 $nightlyFlag

Get-ChildItem "$pwd\deploy" |
ForEach-Object {
    $fileName  = "$pwd\deploy\$_"
    signtool sign /debug /v /tr http://timestamp.digicert.com /a /fd sha256 /td sha256 /f $env:CERT_FILE /as $fileName
    if ($LastExitCode -ne 0) {
         throw "$fileName signing failed"
    }
}