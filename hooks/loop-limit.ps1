$Limit = 3
$StateDir = Join-Path $env:TEMP "mb-al-loop-demo"
New-Item -ItemType Directory -Force -Path $StateDir | Out-Null

$InputJson = [Console]::In.ReadToEnd() | ConvertFrom-Json
$ToolName = $InputJson.tool_name
$SessionId = if ($InputJson.session_id) { $InputJson.session_id } else { "default" }

if ($ToolName -ne "al_build") {
    Write-Output '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
    exit 0
}

$StateFile = Join-Path $StateDir "$SessionId.count"
$Count = 0
if (Test-Path $StateFile) {
    $Count = [int](Get-Content $StateFile)
}
$Count++
Set-Content -Path $StateFile -Value $Count

if ($Count -gt $Limit) {
    $Reason = "Attempt limit ($Limit) reached. The loop stopped. Review the last error and fix it by hand."
    Write-Output (@{hookSpecificOutput=@{permissionDecision="deny"; permissionDecisionReason=$Reason}} | ConvertTo-Json -Compress)
    exit 0
}

$Context = "Attempt $Count of $LIMIT."
Write-Output (@{hookSpecificOutput=@{permissionDecision="allow"; additionalContext=$Context}} | ConvertTo-Json -Compress)
exit 0
