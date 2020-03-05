Param (
    $scriptPath = "$(split-path -parent $MyInvocation.MyCommand.Definition)",
    $basePath = "$((split-path -parent $MyInvocation.MyCommand.Definition).replace('bin',''))",
    $scriptName = "$((split-path -leaf $MyInvocation.MyCommand.Definition).replace('.ps1',''))",
    $projectNameDefault = "$(Split-Path $basePath -leaf)",
    $logPath = (Join-Path(Join-Path (Join-Path (Join-Path (Split-path  $scriptPath  -parent) $stackType) ".logs") $environment) "logs"),
    $logFolder = (Join-Path $logPath $scriptName),
    $Date = (get-date -format yyyyMMdd),
    $force = $false,
    $region="eu-central-1",
    $profileNameMfa = "goaldevMfa",
    $profileName = "goaldev"
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

set-location "C:\renovatio"
Invoke-Expression -Command "$(Join-Path $scriptPath Set-AwsMfaCredentials.ps1) -ProfileName $profileName -ProfileNameMfa $profileNameMfa"
#Invoke-Expression -Command "$(Join-Path $scriptPath Set-AwsMfaCredentials.ps1) -ProfileName $profileName -ProfileNameMfa $profileNameMfa -force $true"

$profileName = "goaldevMfa"


# bootstrap
#Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -ProfileNameMfa -$profileNameMfa -bootstrap $true -region $($region) -project $($projectNameDefault) -action plan"

# taint
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a taint aws_s3_bucket.s3-bucket-logs"

# state rm
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a state rm aws_s3_bucket.s3-bucket-logs"

# show
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a show" | clip


#######################
# network
#######################

# plan
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a plan"

# destroy
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a destroy"

# targeted destroy
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a destroy -target=aws_launch_configuration.management"

# apply
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a apply"

# show
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a show" | clip

# state rm
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a state rm aws_internet_gateway.renovatio-igw"

#######################
# directory service
#######################

# plan
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a plan"

# destroy
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a destroy"

# initialise
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a init"

# apply
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a apply"
  
# state rm
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a state rm aws_network_acl_rule.public_rdp_return_to_internet"

# show
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a show" | clip

#######################
# management
#######################

# plan
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a plan"

# destroy
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a destroy"

# taint
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a taint aws_s3_bucket_object.squid_conf"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a apply"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a apply"

# apply
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a apply"

# state rm
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.public_rdp_return_to_internet"

# show
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a show" | clip

#######################
# web
#######################

# plan
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a plan"

# destroy
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a destroy"

# apply
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a apply"

# state rm
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a state rm aws_network_acl_rule.public_rdp_return_to_internet"

# show
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a show" | clip


#pester
#Invoke-Pester ..

# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a destroy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a destroy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a destroy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a apply"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a apply"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a apply"

# Remove backup files. 
# Get-ChildItem -path c:\renovatio  -recurse -Include "*.backup" | remove-item


# Remove ACL rules #
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.http_proxy_to_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.rdp_public_from_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.https_public_to_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.proxy_port_management_to_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.http_public_to_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.rdp_management_from_public"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.proxy_port_proxy_from_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_proxy_from_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ssh_proxy_from_management"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.https_proxy_to_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_public_to_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.proxy_port_proxy_from_management"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_management_to_public"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.http_public_from_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_public_from_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.rdp_public_to_management"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ssh_management_to_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_management_from_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_public_from_management"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.proxy_port_proxy_to_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_public_to_internet"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.https_public_from_proxy"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_proxy_to_management"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_management_from_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_udp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_tcp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_management_from_directoryservice"

# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_tcp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_udp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_management_from_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_management_from_directoryservice"
#
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_to_vpc"
## Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_to_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_ports_directoryservice_from_vpc"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_tcp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.dns_udp_management_to_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_tcp_management_from_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_network_acl_rule.ephemeral_udp_management_from_directoryservice"
# Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_management -r eu-central-1 -a state rm aws_vpc_dhcp_options_association.vpc-dns"#


function Get-AllResources {
    $lines = ""
    foreach ($file in (Get-ChildItem .  -Filter *.tf)) {
        foreach ($line in (Get-Content $file)) {
            if ($line -match "resource" -and $line -match "`" `"") {
                $lines = $lines + $line.Replace('resource "',''.replace('" "','.')) + "`n"
            }
        }
    }
    return $lines.trim().replace("`" `"",".").replace("`" {","").Split([Environment]::NewLine)
}

function Remove-AllNaclRulesFromState {
    Set-location C:\renovatio\components\network
    "Determining component directory"
    $component = Get-location | split-path -leaf
    foreach ($resource in Get-allResources) {
        if ($resource -match "rule") {
            "Removing resource $resource"
            Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c $component -e devel_shared_$component -r eu-central-1 -a state rm $($resource)"
        }
    }
}

# Remove-AllNaclRulesFromState


# destroy timeline
#Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a destroy"
#Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a destroy"
#Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a destroy"
#Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a destroy"

# apply timeline
Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c network -e devel_shared_network -r eu-central-1 -a apply"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformNetwork.Tests.ps1"
Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c directoryservice -e devel_shared_directoryservice -r eu-central-1 -a apply"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformNetwork.Tests.ps1"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformDirectoryService.Tests.ps1"
Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c management -e devel_shared_management -r eu-central-1 -a apply"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformNetwork.Tests.ps1"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformDirectoryService.Tests.ps1"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformManagement.Tests.ps1"
Invoke-Expression -Command "$(Join-Path $scriptPath terraform.ps1) -ProfileName $profileName -p renovatio -c web -e devel_web -r eu-central-1 -a apply"
Invoke-Expression -Command "$scriptPath\..\test\Get-TerraformWeb.Tests.ps1"

