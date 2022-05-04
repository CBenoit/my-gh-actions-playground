#!/bin/env pwsh

param(
    [Parameter(Mandatory=$true)]
    [string] $Token,
    [string] $Path = "."
)

$ErrorActionPreference = "Stop"

$MyInvocation.MyCommand.Parameters `
    | Format-Table -AutoSize `
        @{ Label = "Argument"; Expression = { $_.Key }; },
        @{ Label = "Value"; Expression = { try { (Get-Variable -Name $_.Key).Value } catch { "" } }; }
Write-Host

Set-Location -Path "$Path"

$Args = @('workspaces', 'publish')
$Args = @('--from-git')
$Args = @('--yes')
$Args += @('--token', $Token)
Write-Host "Args: $Args"

cargo +stable $Args
