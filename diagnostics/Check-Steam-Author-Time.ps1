# Ballest Map Roulette: author-time source diagnostic
# Research utility only. Does NOT install/modify game files or send private data.
# Requests PUBLIC Workshop item data from the Steam Web API without an API key.
# Run with: powershell -NoProfile -ExecutionPolicy Bypass -File ".\Check-Steam-Author-Time.ps1"
# Optional: -WorkshopId "1234567890"

[CmdletBinding()]
param(
    [string]$WorkshopId = "",
    [string]$MapName = "Ballistic Banzai",
    [double]$ExpectedAuthorSeconds = 27.581
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "MAP ROULETTE | STEAM AUTHOR-TIME DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "Read-only: no installation, game changes, API keys, or uploads."
Write-Host ""

# v0.1.5 writes "Learned author time for map <id>: <seconds> seconds"
# to Plugin Manager's log after loading a new map.
if ([string]::IsNullOrWhiteSpace($WorkshopId)) {
    $log = Join-Path $env:LOCALAPPDATA "Ballest\Saved\PluginManager\host.log"
    if (Test-Path -LiteralPath $log) {
        $logText = [IO.File]::ReadAllText($log)
        $regex = [regex]'Learned author time for map\s+(\d+):\s+([0-9]+(?:\.[0-9]+)?)\s+seconds'
        $found = @($regex.Matches($logText))
        $candidate = $null
        for ($i = $found.Count - 1; $i -ge 0; $i--) {
            $hit = $found[$i]
            $time = [double]::Parse($hit.Groups[2].Value, [Globalization.CultureInfo]::InvariantCulture)
            if ([Math]::Abs($time - $ExpectedAuthorSeconds) -le 0.01) {
                $candidate = $hit
                break
            }
        }
        if ($null -ne $candidate) {
            $WorkshopId = $candidate.Groups[1].Value
            Write-Host "Found the previously loaded map in the Plugin Manager log." -ForegroundColor Green
            Write-Host "Observed in game: $ExpectedAuthorSeconds seconds"
        } else {
            Write-Host "No matching author-time log entry was found in this session." -ForegroundColor Yellow
            Write-Host "Tip: load Ballistic Banzai once in Ballest, then run this script again."
        }
    } else {
        Write-Host "Plugin Manager host.log was not found." -ForegroundColor Yellow
    }
}

if ([string]::IsNullOrWhiteSpace($WorkshopId)) {
    $WorkshopId = Read-Host "Enter the numeric Steam Workshop item ID (or press Enter to quit)"
}
if ($WorkshopId -notmatch '^[0-9]{5,20}$') {
    Write-Host "No valid Workshop ID was provided. Nothing was changed." -ForegroundColor Yellow
    exit 2
}

Write-Host "Workshop ID: $WorkshopId"
Write-Host "Known Hub author time for $MapName : $ExpectedAuthorSeconds seconds"
Write-Host "Requesting PUBLIC item details from Steam..." -ForegroundColor Cyan

$uri = 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/'
$form = @{}
$form['itemcount'] = '1'
$form['publishedfileids[0]'] = $WorkshopId

try {
    $data = Invoke-RestMethod -Uri $uri -Method Post -Body $form -ContentType 'application/x-www-form-urlencoded' -TimeoutSec 20
} catch {
    Write-Host "Steam request failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check connectivity and the Workshop item ID. The test made no game changes."
    exit 3
}

$details = @($data.response.publishedfiledetails) | Where-Object {
    $_ -and ([string]$_.publishedfileid -eq $WorkshopId)
} | Select-Object -First 1
if ($null -eq $details -or [int]$details.result -ne 1) {
    Write-Host "Steam did not return a valid public item. Item result: $($details.result)" -ForegroundColor Yellow
    exit 4
}

Write-Host ""
Write-Host "Item title returned by Steam: $($details.title)" -ForegroundColor Green
if ([string]$details.title -ne $MapName) {
    Write-Host "WARNING: Title does not match the expected test map. Verify the ID." -ForegroundColor Yellow
}
$keys = @($details.PSObject.Properties.Name) | Sort-Object
Write-Host ""
Write-Host "Returned Steam response fields:"
Write-Host ($keys -join ", ")

$potential = @($details.PSObject.Properties | Where-Object {
    $_.Name -match '(?i)author.?time|metadata|medal|target.?time|goal.?time|best.?time'
})
Write-Host ""
if ($potential.Count -eq 0) {
    Write-Host "RESULT: The public endpoint exposed NO explicit author-time/medal/metadata field." -ForegroundColor Yellow
    Write-Host "This does NOT prove the game lacks this information: the Steam client UGC API may expose more."
} else {
    Write-Host "Potential fields (UNVERIFIED: must match the game's 27.581s value):" -ForegroundColor Yellow
    foreach ($prop in $potential) {
        $preview = [string]$prop.Value
        if ($preview.Length -gt 500) { $preview = $preview.Substring(0,500) + "... [truncated]" }
        Write-Host (" - " + $prop.Name + ": " + $preview)
    }
}
Write-Host ""
Write-Host "IMPORTANT: time_created and time_updated are publication timestamps, NOT author times."
Write-Host "Do not infer author time from rating, player times, Steam tags, play count, or file size."
Write-Host ""
Write-Host "Test complete. Please share ONLY the lines above starting with 'Returned Steam response fields:'" -ForegroundColor Cyan
Write-Host "and 'RESULT:' (or 'Potential fields'). No private logs are needed."
