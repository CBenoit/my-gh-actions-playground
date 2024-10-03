#!/bin/env pwsh

param(
    [Parameter(Mandatory=$true)]
    [string] $RepoName,
    [Parameter(Mandatory=$true)]
    [int] $PullRequestId,
    [Parameter(Mandatory=$true)]
    [string] $Branch,
    [Parameter(Mandatory=$true)]
    [string] $TemplatePath
)

$ErrorActionPreference = "Stop"

$MyInvocation.MyCommand.Parameters `
    | Format-Table -AutoSize `
        @{ Label = "Argument"; Expression = { $_.Key }; },
        @{ Label = "Value"; Expression = { try { (Get-Variable -Name $_.Key).Value } catch { "" } }; }
Write-Host

Write-Host ">> Read template file at $TemplatePath"

$body = Get-Content -Path "$TemplatePath"

Write-Host '>> Create new comment'

$args = @(
    'api',
    '-H', 'Accept: application/vnd.github.v3+json',
    '-f', "body=$body",
    '--method', 'POST',
    "/repos/$RepoName/issues/$PullRequestId/comments"
)

Invoke-Cmd 'gh' $args | Out-Null

