#!/bin/env pwsh

param(
    [Parameter(Mandatory=$true)]
    [string] $Token,
    [string] $Path = "."
)

$ErrorActionPreference = "Stop"

Set-Location -Path "$Path"

$Args = @('workspaces', 'publish')
$Args = @('--from-git')
$Args = @('--yes')
$Args += @('--token', ${{ inputs.crates-io-token }})
Write-Host "Args: $Args"

cargo +stable $Args
