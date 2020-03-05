param (
    $scriptPath = "$(split-path -parent $MyInvocation.MyCommand.Definition)",
    $scriptName = "$((split-path -leaf $MyInvocation.MyCommand.Definition).replace('.ps1',''))",
    $logPath = (Join-Path (Join-Path  (Split-path  $scriptPath  -parent) ".logs") $environment),
    $logFolder = (Join-Path $logPath $scriptName),
    $Date = (get-date -format yyyyMMdd),
    $force = $false,
    $profileNameMfa = "goaldevMfa",
    $profileName = "goaldev",
    $region = "eu-central-1",
    $mfaCode = $null
)
function Out-Results { # outputting everything to Log file and console
    if (!(Test-Path $logFolder) -and $environment -notmatch "none-set") {
        New-Item -ItemType Directory -Path "$logFolder" -Force
    }
    Write-Host $args[0]
    if ($environment -notmatch "none-set") {
        $args[0] | out-file ($script:logFile = (join-path $logFolder "$($Date).log")) -Append 
        if ($error) {
            $error | out-file "$script:logFile" -Append 
            $error.clear()
            $script:errorExists = $true
        }
    }
}

function New-ScriptInitialization  {
    $error.clear()
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results "Setting defaults"
    Set-DefaultAWSRegion -Region $region
}
function Out-Parameters { # Listing the variables and their values
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    Out-Results "Variables in use:"
    Out-Results "`$scriptPath = `"$($scriptPath)`""
    Out-Results "`$scriptName = `"$($scriptName)`""
    Out-Results "`$logPath = `"$($logPath)`""
    Out-Results "`$logFolder = `"$($logFolder)`""
    Out-Results "`$logFolder = `"$($logFolder)`""
    Out-Results "`$script:logFile = `"$($script:logFile)`""
    Out-Results "`$Date = `"$($Date) `""
    Out-Results "`$mfaCode = `"$($mfaCode)`""
    Out-Results "`$profileNameMfa = `"$($profileNameMfa)`""
    Out-Results "`$profileName = `"$($profileName)`""
    Out-Results "`$region = `"$($region)`""

}

function Test-Value { # The value of running this script. $true = worth it
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    if ($force) {
        Out-Results "Forced run"
        return $true
    }
    try {
        Out-Results "Testing the MFA Profile"
        Set-AWSCredential -ProfileName $profileNameMfa
        Set-DefaultAWSRegion -Region $region
        $stsCallerIdentity = Get-STSCallerIdentity
        $script:iamIronMan = $stsCallerIdentity.Arn
        $script:awsAccountId = $stsCallerIdentity.Account
        if ($iamIronMan) {
            Out-Results "AWS Credentials Found. Using $($iamIronMan)"
            return $false
        } else {
            Out-Results "No AWS Credentials Found. `"aws sts get-caller-identity --query 'Arn' --output text`" responded with ARN '${iam_iron_man}'"
            return $true
        }
        if (!([bool]($mfaExpiry = [datetime][Environment]::GetEnvironmentVariable("AWS_MFA_EXPIRY","User")))) {
            Out-Results "`AWS_MFA_EXPIRY isn't set"
            return $true
        } else {
            if ($(($mfaExpiry -(Get-Date)).hours) -gt 0) {
                Out-Results "`AWS_MFA_EXPIRY is later than the current time. It won't expire for $(($mfaExpiry -(Get-Date)).hours) hours. Not worth resetting AWS credentials"
                return $false
            } else {
                Out-Results "`AWS_MFA_EXPIRY has expired so let's go."
                return $true
            }
        }
    } catch {
        return $true
    }
}

function Remove-Credentials() {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID",$null,"User")
    [Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY",$null,"User")
    [Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN",$null,"User")
    [Environment]::SetEnvironmentVariable("AWS_MFA_EXPIRY",$null,"User")
    try {
        Out-Results "Removing previous $($profileNameMfa) profile"
        Remove-AWSCredentialProfile $profileNameMfa -Force
    } catch {
        Out-Results "Couldn't remove $($profileNameMfa) profile. Potentially non-existent already."
    }
}



function Get-CredentialsWithMfa  {
    $error.clear()
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Set-AWSCredential -ProfileName $profileName
    if ($mfaCode -eq $null) {
        $script:mfaCode = Read-Host -Prompt 'Please enter your mfa code'
    }
    try {
        $serialNumber = (Get-IAMMFADevice -ProfileName $profileName).SerialNumber
    } catch {
        Out-Results "Failed to retrieve MFA serial number - this should work without MFA - please check"
        exit 1
    }
    Out-Results "`$serialNumber = $serialNumber"
    try {
        $script:sessionToken = Get-STSSessionToken -TokenCode $mfaCode -SerialNumber $serialNumber -ProfileName $profileName -Region $region
    } catch {
        Out-results "Failed to retrieve SessionToken"
        Out-Results $sessionToken
        throw "Failed to retrieve SessionToken"
    }
    Out-Results "`$sessionToken = $sessionToken"
}
function Set-CredentialsWithMfa  {
    $error.clear()
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    [Environment]::SetEnvironmentVariable("AWS_PROFILE", "$profileNameMfa", "User")
    [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "$([string]$sessionToken.AccessKeyId)", "User")
    [Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "$([string]$sessionToken.SecretAccessKey)", "User")
    [Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", "$([string]$sessionToken.SessionToken)", "User")
    $expiryString = [string]($sessionToken.Expiration)
    [Environment]::SetEnvironmentVariable("AWS_MFA_EXPIRY", "$expiryString", "User")

    $env:AWS_PROFILE = [Environment]::GetEnvironmentVariable("AWS_PROFILE", "User")
    $env:AWS_ACCESS_KEY_ID = [Environment]::GetEnvironmentVariable("AWS_ACCESS_KEY_ID", "User")
    $env:AWS_SECRET_ACCESS_KEY=[Environment]::GetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "User")
    $env:AWS_SESSION_TOKEN=[Environment]::GetEnvironmentVariable("AWS_SESSION_TOKEN", "User")
    $env:AWS_MFA_EXPIRY=[Environment]::GetEnvironmentVariable("AWS_MFA_EXPIRY", "User")
    Set-AWSCredentials -StoreAs $profileNameMfa -AccessKey "$([string]$sessionToken.AccessKeyId)" -SecretKey "$([string]$sessionToken.SecretAccessKey)" -SessionToken "$([string]$sessionToken.SessionToken)"
}

Out-Results
New-ScriptInitialization
Out-Parameters
if (Test-Value) {
    Get-CredentialsWithMfa
    Remove-Credentials
    Set-CredentialsWithMfa
    RefreshEnv
    Out-Results "profile is  $env:AWS_PROFILE"
}