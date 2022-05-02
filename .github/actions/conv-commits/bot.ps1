#!/bin/env pwsh

param(
    [Parameter(Mandatory=$true)]
    [string] $RepoName,
    [Parameter(Mandatory=$true)]
    [int] $PullRequestId,
    [string] $BaseRef = "main",
    [string] $HeadRef = "HEAD",
    [string] $Header = ":robot: **Conventional Commits Summary** :arrow_heading_down:",
    [string] $Message = "This repository adheres to the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/).",
    [string] $Footer = '[this comment will be updated automatically]'
)

$ErrorActionPreference = "Stop"

$MyInvocation.MyCommand.Parameters `
    | Format-Table -AutoSize `
        @{ Label = "Argument"; Expression = { $_.Key }; },
        @{ Label = "Value"; Expression = { try { (Get-Variable -Name $_.Key).Value } catch { "" } }; }
Write-Host

function Invoke-Cmd
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Name,
        [Parameter(Mandatory=$true)]
        [string[]] $Args,
        [switch] $IgnoreFailure
    )    

    Write-Host "Invoke '${Name}' $($Args | Join-String -FormatString '''{0}''' -Separator ' ')"
    $output = & $Name $Args
    $failed = -not $?

    if ($failed -and (-not $IgnoreFailure))
    {
        throw "${Name} invocation failed"
    }

    $output
}

function Get-Comments
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $RepoName,
        [Parameter(Mandatory=$true)]
        [int] $PullRequestId
    )

    $args = @(
        'api',
        '-H', 'Accept: application/vnd.github.v3+json',
        "/repos/$RepoName/issues/$PullRequestId/comments"
    )
    Invoke-Cmd 'gh' $args | ConvertFrom-Json
}

function Fetch-History
{
    param(
        [Parameter(Mandatory=$true)]
        [int] $PullRequestId
    )

    $response = Invoke-Cmd 'gh' @('pr', 'view', $PullRequestId, '--json', 'commits') | ConvertFrom-Json
    $nbCommits = $response.commits.Length
    Write-Host "$nbCommits commits to fetch for this PR"
    Invoke-Cmd 'git' @('fetch', '--no-tags', '--prune', '--progress', '--no-recurse-submodules', '--deepen', $nbCommits) | Out-Null
}

function Update-Status
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $RepoName,
        [Parameter(Mandatory=$true)]
        [int] $PullRequestId,
        [Parameter(Mandatory=$true)]
        [string] $Body,
        $Comment
    )

    $args = @(
        'api',
        '-H', 'Accept: application/vnd.github.v3+json',
        '-f', "body=$Body"
    )

    if ($Comment -eq $null)
    {
        Write-Host 'Create new comment'
        $args += @('--method', 'POST')
        $args += @("/repos/$RepoName/issues/$PullRequestId/comments")
    }
    else
    {
        Write-Host 'Update existing comment'
        $args += @('--method', 'PATCH')
        $args += @("/repos/$RepoName/issues/comments/$($Comment.id)")
    }

    Invoke-Cmd 'gh' $args | Out-Null
}

Fetch-History $PullRequestId

$comments = Get-Comments `
    -RepoName $RepoName `
    -PullRequestId $PullRequestId
$filteredComments = $comments.Where(
    { $_.body.StartsWith($CommentHeader, "CurrentCultureIgnoreCase") },
    "First"
)
$comment = $filteredComments[0]

if ($comment -ne $null)
{
    Write-Host "Found already existing bot comment"
}

$status = Invoke-Cmd -Name 'convco' -Args @('check', "$BaseRef..$HeadRef") -IgnoreFailure | Out-String

if ($status.Contains('failed'))
{
    Write-Host "Detected some commits not adhering to the Conventional Commit specification"
}

if (($comment -ne $null) -or $status.Contains('failed'))
{
    $body = @(
        $Header,
        '',
        $Message,
        '',
        '**Status**',
        '',
        $status.Replace('"', '\"'),
        $Footer
    ) -Join "`n"

    Update-Status `
        -RepoName $RepoName `
        -PullRequestId $PullRequestId `
        -Body $body `
        -Comment $comment
}
