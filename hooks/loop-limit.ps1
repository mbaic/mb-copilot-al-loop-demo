# Blocks al_build after 3 attempts per chat session.
# Runs as a PreToolUse hook from the al-build-loop agent's frontmatter.
$Limit = 3
$StateDir = Join-Path $env:TEMP "mb-al-loop-demo"
New-Item -ItemType Directory -Force -Path $StateDir | Out-Null

$InputJson = [Console]::In.ReadToEnd() | ConvertFrom-Json
$ToolName = [string]$InputJson.tool_name
# The session ID becomes a file name, so keep only safe characters.
$SessionId = ([string]$InputJson.session_id) -replace '[^A-Za-z0-9._-]', ''
if (-not $SessionId) { $SessionId = "default" }

# Other tools: return no decision, so the normal approval flow applies.
if ($ToolName -ne "al_build" -and $ToolName -notlike "*/al_build") {
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
    Write-Output (@{hookSpecificOutput=@{hookEventName="PreToolUse"; permissionDecision="deny"; permissionDecisionReason=$Reason}} | ConvertTo-Json -Compress)
    exit 0
}

$Context = "Attempt $Count of $Limit."
Write-Output (@{hookSpecificOutput=@{hookEventName="PreToolUse"; additionalContext=$Context}} | ConvertTo-Json -Compress)
exit 0
