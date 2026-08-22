$ErrorActionPreference = 'Continue'

$repoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = $MyInvocation.MyCommand.Path
$pidFile = Join-Path $repoPath '.autopush.pid'
$logFile = Join-Path $repoPath '.autopush.log'

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $logFile -Value "[$timestamp] $Message"
}

function Ensure-ReadmeEntries {
    param([string[]]$JavaFileNames)

    if (-not $JavaFileNames -or $JavaFileNames.Count -eq 0) {
        return $false
    }

    $readmePath = Join-Path $repoPath 'README.md'
    $changed = $false

    if (Test-Path $readmePath) {
        $content = Get-Content -Path $readmePath -Raw
    } else {
        $content = "# Step_semester_3`r`n`r`nThis repository contains basic Java practice programs for semester work.`r`n`r`n## Programs`r`n`r`n"
        $changed = $true
    }

    if ($content -notmatch '(?m)^## Programs\s*$') {
        if ($content -notmatch "\r?\n$") { $content += "`r`n" }
        $content += "`r`n## Programs`r`n`r`n"
        $changed = $true
    }

    $uniqueNames = $JavaFileNames | Sort-Object -Unique
    foreach ($name in $uniqueNames) {
        $entryPattern = '(?m)^- `'+[regex]::Escape($name)+'`(?:\s|-|$)'
        if ($content -notmatch $entryPattern) {
            if ($content -notmatch "\r?\n$") { $content += "`r`n" }
            $content += ('- `'+$name+'` - Java program.' + "`r`n")
            $changed = $true
        }
    }

    if ($changed) {
        Set-Content -Path $readmePath -Value $content
    }

    return $changed
}

if (Test-Path $pidFile) {
    $existingPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($existingPid) {
        $existing = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Log "Watcher already running with PID $existingPid. Exiting."
            exit 0
        }
    }
}

Set-Content -Path $pidFile -Value $PID
Write-Log "Auto-push watcher started. PID=$PID Repo=$repoPath"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.Filter = '*'
$watcher.IncludeSubdirectories = $false
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, Size, CreationTime'
$watcher.EnableRaisingEvents = $true

$queue = New-Object 'System.Collections.Generic.HashSet[string]'

function Add-QueuedFile {
    param([string]$FullPath)
    if (-not $FullPath) { return }
    if ($FullPath -like "$repoPath\.git*") { return }
    if (-not (Test-Path $FullPath -PathType Leaf)) { return }
    if ($FullPath -eq $scriptPath) { return }
    if ($FullPath -eq $pidFile) { return }
    if ($FullPath -eq $logFile) { return }
    [void]$queue.Add($FullPath)
}

$createdSub = Register-ObjectEvent -InputObject $watcher -EventName Created -Action {
    Add-QueuedFile -FullPath $Event.SourceEventArgs.FullPath
}

$changedSub = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action {
    Add-QueuedFile -FullPath $Event.SourceEventArgs.FullPath
}

while ($true) {
    Start-Sleep -Seconds 4

    if ($queue.Count -eq 0) { continue }

    $files = @($queue)
    $queue.Clear()
    $newJavaFileNames = New-Object 'System.Collections.Generic.HashSet[string]'

    foreach ($fullPath in $files) {
        $name = [System.IO.Path]::GetFileName($fullPath)
        $tracked = git -C $repoPath ls-files --error-unmatch -- "$name" 2>$null
        if ($LASTEXITCODE -ne 0) {
            git -C $repoPath add -- "$name"
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Staged new file: $name"
                if ([System.IO.Path]::GetExtension($name).ToLowerInvariant() -eq '.java') {
                    [void]$newJavaFileNames.Add($name)
                }
            } else {
                Write-Log "Failed to stage new file: $name"
            }
        }
    }

    if ($newJavaFileNames.Count -gt 0) {
        $readmeUpdated = Ensure-ReadmeEntries -JavaFileNames @($newJavaFileNames)
        if ($readmeUpdated) {
            git -C $repoPath add -- 'README.md'
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Updated README.md with new Java file entries."
            } else {
                Write-Log "Failed to stage README.md update."
            }
        }
    }

    git -C $repoPath diff --cached --quiet
    if ($LASTEXITCODE -ne 0) {
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        git -C $repoPath commit -m "Auto-sync new files: $stamp"
        if ($LASTEXITCODE -eq 0) {
            git -C $repoPath push
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Pushed auto-sync commit."
            } else {
                Write-Log "Push failed. Trying pull --rebase + push retry."
                git -C $repoPath pull --rebase origin main
                if ($LASTEXITCODE -eq 0) {
                    git -C $repoPath push
                    if ($LASTEXITCODE -eq 0) {
                        Write-Log "Push retry succeeded after rebase."
                    } else {
                        Write-Log "Push retry failed after successful rebase."
                    }
                } else {
                    Write-Log "pull --rebase failed; leaving commit local for manual resolution."
                }
            }
        } else {
            Write-Log "No commit created."
        }
    }
}
