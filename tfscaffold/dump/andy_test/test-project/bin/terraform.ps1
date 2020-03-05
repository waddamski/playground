# Terraform Scaffold
#
# Ported from the bash script version 1.4.2
# - handles remote state
# - uses consistent .tfvars files for each environment
##
# Set Script Version
##
Param (
    $scriptPath = "$(split-path -parent $MyInvocation.MyCommand.Definition)",
    $basePath = "$((split-path -parent $MyInvocation.MyCommand.Definition).replace('bin',''))",
    $scriptName = "$((split-path -leaf $MyInvocation.MyCommand.Definition).replace('.ps1',''))",
    $projectNameDefault = "$(Split-Path $scriptPath -leaf)",
    $logPath = "$((split-path -parent $MyInvocation.MyCommand.Definition).replace('bin','.logs'))",
    $logFolder = (Join-Path $logPath $scriptName),
    $Date = (get-date -format yyyyMMdd),
    $force = "",
    $profileName = "goaldevMfa",
    $mfaCode = $null,
    $scriptVersion = "1.4.2",
    $bootstrap = $false,
    $a="",
    $b="",
    $c="",
    $e="",
    $g="",
    $i="",
    $p="",
    $r="",
    $action="",
    $bucketPrefix="",
    $component="",
    $environment="",
    $group="",
    $buildId="",
    $project="",
    $region="",
    $version="1.4.2",
    $quiet = $false,
    [parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$extraArgs
    
)

function Out-Results { # outputting everything to Log file and console
    if (!(Test-Path $logFolder) -and $environment -notmatch "none-set") {
        New-Item -ItemType Directory -Path "$logFolder" -Force
    }
    if (!($quiet)) {Write-Host $args[0]}
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
}

function Convert-Variables {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    if (!($action)) {$script:action=$a}
    if (!($bucketPrefix)) {$script:bucketPrefix=$b}
    if (!($component)) {$script:component=$c}
    if (!($environment)) {$script:environment=$e}
    if (!($group)) {$script:group=$g}
    if (!($buildId)) {$script:buildId=$i}
    if (!($project)) {$script:project=$p}
    if (!($region)) {$script:region=$r}
}
function Out-Parameters { # Listing the variables and their values
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    Out-Results "Variables in use:"
    Out-Results "`$scriptPath = `"$($scriptPath)`""
    Out-Results "`$scriptName = `"$($scriptName)`""
    Out-Results "`$basePath = `"$($basePath)`""
    Out-Results "`$projectNameDefault = `"$($projectNameDefault)`""
    Out-Results "`$logPath = `"$($logPath)`""
    Out-Results "`$logFolder = `"$($logFolder)`""
    Out-Results "`$logFolder = `"$($logFolder)`""
    Out-Results "`$script:logFile = `"$($script:logFile)`""
    Out-Results "`$Date = `"$($Date) `""
    Out-Results "`$mfaCode = `"$($waitMinutesForLogging)`""
    Out-Results "`$profileName = `"$($profileName)`""
    Out-Results "`$region = `"$($region)`""
    Out-Results "`$scriptVersion = `"$($scriptVersion)`""
    Out-Results "`$action=`"$($action)`""
    Out-Results "`$bucketPrefix=`"$($bucketPrefix)`""
    Out-Results "`$component=`"$($component)`""
    Out-Results "`$environment=`"$($environment)`""
    Out-Results "`$group=`"$($group)`""
    Out-Results "`$buildId=`"$($buildId)`""
    Out-Results "`$project=`"$($project)`""
    Out-Results "`$region=`"$($region)`""
    Out-Results "`$extraArgs=`"$($extraArgs)`""
}

function Clear-Mess {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    Remove-Item -Path "$(Join-Path (Get-Location) backend_terraformscaffold.tf)" -Force
    Set-Location $basePath
}
function Set-Variables { # Listing the variables and their values
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    if (!($region)) {
        Out-Results "Region must be specified"
        throw "Region must be specified"
    }
    if (!($project)) {
        Out-Results "Project must be specified"
        throw "Project must be specified"
    }
    # Bootstrapping is special
    if ($bootstrap) {
        ###############################
        # REMOVE THIS WHEN FIXED
        ###############################
        Out-Results "Bootstrapping is not yet supported in the PowerShell version of Scaffold"
        throw "Bootstrapping is not yet supported in the PowerShell version of Scaffold"
        #TODO
        if ($component) {
            Out-Results "The --bootstrap parameter and the -c/--component parameter are mutually exclusive"
            throw "The --bootstrap parameter and the -c/--component parameter are mutually exclusive"
        }
        if ($environment) {
            Out-Results "The --bootstrap parameter and the -e/--environment parameter are mutually exclusive"
            throw "The --bootstrap parameter and the -c/--component parameter are mutually exclusive"
        }
        if ($buildId) {
            Out-Results "The --bootstrap parameter and the -c/--component parameter are mutually exclusive"
            throw "The --bootstrap parameter and the -i/--build-id parameter are mutually exclusive. We do not currently support plan files for bootstrap"
        }
    } else {
        # Validate component to work with
        if (!($component)) {
            Out-Results "Required argument missing: -c/--component"
            throw "Required argument missing: -c/--component"
        }
        # Validate environment to work with
        if (!($environment)) {
            Out-Results "Required argument missing: -e/--environment"
            throw "Required argument missing: -e/--environment"
        }
    }
    if (!($action)) {
        Out-Results "Required argument missing: -a/--action"
        throw "Required argument missing: -a/--action"
    }

    # Validate AWS Credentials

    $stsCallerIdentity = Get-STSCallerIdentity -Region $region
    $script:iamIronMan = $stsCallerIdentity.Arn
    $script:awsAccountId = $stsCallerIdentity.Account

    if ($iamIronMan) {
        Out-Results "AWS Credentials Found. Using $($iamIronMan)"
    } else {
        Out-Results "No AWS Credentials Found. `"aws sts get-caller-identity --query 'Arn' --output text`" responded with ARN '${iam_iron_man}'"
        throw "No AWS Credentials Found. `"aws sts get-caller-identity --query 'Arn' --output text`" responded with ARN '${iam_iron_man}'"
    }
    if ($stsCallerIdentity.Account) {
        Out-Results "AWS Account ID: $($awsAccountId)"
    } else {
        Out-Results "Couldn't determine AWS Account ID. `"aws sts get-caller-identity --query 'Account' --output text`" provided no output";
        throw "Couldn't determine AWS Account ID. `"aws sts get-caller-identity --query 'Account' --output text`" provided no output";
    }
    # Validate S3 bucket. Set default if undefined
    if ($bucketPrefix) {
        $script:bucket="$bucketPrefix-$awsAccountId-$region"
        Out-Results "Using S3 bucket s3://${bucket}"
    } else {
        $script:bucket="$project-terraformscaffold-$awsAccountId-$region"
        Out-Results "No bucket prefix specified. Using S3 bucket s3://${bucket}"
    }
    if ($bootstrap) {
        $script:componentPath = $(Join-Path $basePath "bootstrap")
    } else {
        $script:componentPath = $(Join-Path (Join-Path $basePath "components") $component)
    }
    if (!(Test-Path $componentPath)) {
        Out-Results "Component path $($componentPath) does not exist"
        throw "Component path $($componentPath) does not exist"
    }
    switch ($action) {
        "apply"{
            $refresh="-refresh=true";
        }
        "destroy"{
            $script:destroy='-destroy';
            $script:force='-force';
            $script:refresh="-refresh=true";
        }
        "plan"{
            $script:refresh="-refresh=true";
        }
        "plan-destroy"{
            $script:action="plan";
            $script:destroy="-destroy";
            $script:refresh="-refresh=true";
        }
    }
}

function Set-Credentials {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    Out-Results "Setting profile to $($profileName)"
    Set-AWSCredential -ProfileName $profileName
    Out-Results "Setting region to $($region)"
    Set-DefaultAWSRegion -Region $region
}
function Set-TerraformOptions {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    # Tell terraform to moderate its output to be a little
    # more friendly to automation wrappers
    # Value is irrelavant, just needs to be non-null
    $env:TF_IN_AUTOMATION="true";
    
    # Configure the plugin-cache location so plugins are not
    # downloaded to individual components
    $defaultPluginCacheDir= "$(Join-Path $scriptPath plugin-cache)"
    $env:TF_PLUGIN_CACHE_DIR="$($defaultPluginCacheDir)"
    try {
        New-Item -ItemType Directory -Path $defaultPluginCacheDir -force
    }
    catch {
        Out-Results "Problem creating $($defaultPluginCacheDir)"
        throw "Problem creating $($defaultPluginCacheDir)"
    }
    # Clear cache, safe enough as we enforce plugin cache
    Remove-Item -Path "$(join-Path $componentPath 'terraform')" -Force -ErrorAction SilentlyContinue

    # Make sure we're running in the component directory
    Set-Location $componentPath
    $script:componentName = $(Split-Path $componentPath -Leaf)

    # Check for presence of tfenv (https://github.com/kamatama41/tfenv)
    # and a .terraform-version file. If both present, ensure required
    # version of terraform for this component is installed automagically.
    #tfenv_bin="$(which tfenv 2>/dev/null)";
    #if [[ -n "${tfenv_bin}" && -x "${tfenv_bin}" && -f .terraform-version ]]; then
    #${tfenv_bin} install;
    #fi; #TODO    
}

function Build-Parameters {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results ""
    # Regardless of bootstrapping or not, we'll be using this string.
    # If bootstrapping, we will fill it with variables,
    # if not we will fill it with variable file parameters

    if ($bootstrap) {
        if ($action -match "destroy") {
            Out-Results "You cannot destroy a bootstrap bucket using terraformscaffold, it's just too dangerous. If you're absolutely certain that you want to delete the bucket and all contents, including any possible state files environments and components within this project, then you will need to do it from the AWS Console. Note you cannot do this from the CLI because the bootstrap bucket is versioned, and even the --force CLI parameter will not empty the bucket of versions"
            throw "You cannot destroy a bootstrap bucket using terraformscaffold, it's just too dangerous. If you're absolutely certain that you want to delete the bucket and all contents, including any possible state files environments and components within this project, then you will need to do it from the AWS Console. Note you cannot do this from the CLI because the bootstrap bucket is versioned, and even the --force CLI parameter will not empty the bucket of versions"
        }

        # Bootstrap requires explicitly and only these parameters
        $script:tfVarParams=""
        $script:tfVarParams+=" -var region=${region}"
        $script:tfVarParams+=" -var project=${project}"
        $script:tfVarParams+=" -var bucket_name=${bucket}"
        $script:tfVarParams+=" -var awsAccountId=${awsAccountId}"
    } else {
        # Run pre_apply.sh
        # TODO: Rename, rework or remove. This is pre-everything, not just apply.
        #if [ -f "pre_apply.sh" ]; then
        #bash pre_apply.sh "${region}" "${environment}" "${action}";
        #((status=status+"$?"));
        #TODO

        # Pull down secret TFVAR file from S3
        # Anti-pattern and security warning: This secrets mechanism provides very little additional security.
        # It permits you to inject secrets directly into terraform without storing them in source control or unencrypted in S3.
        # Secrets will still be stored in all copies of your state file - which will be stored on disk wherever this script is run and in S3.
        # This script does not currently support encryption of state files.
        # Use this feature only if you're sure it's the right pattern for your use case.
        $script:secrets=@()
        $script:secretsFileName="secret.tfvars.enc"
        $script:secretsFilePath="$(Join-Path build $secretsFileName)"
        try {
            $secretsFile = Get-S3Object -BucketName $bucket -Key "$($project)/$($awsAccountId)/$($region)/$($environment)/$($secretsFileName)" -ErrorAction SilentlyContinue
        }
        catch {

        }
        if ($secretsFile) {
            New-Item -ItemType Directory -Path build -Force
            try {
                Copy-S3Object -BucketName $secretsFile.BucketName -Key $secretsFile.Key -LocalFile $secretsFileName
            }
            catch {
                Out-Results "S3 secrets file is present, but inaccessible. Ensure you have permission to read s3://$($bucket)/$($project)/$($awsAccountId)/$($region)/$($environment)/$($secretsFileName)"
                throw "S3 secrets file is present, but inaccessible. Ensure you have permission to read s3://$($bucket)/$($project)/$($awsAccountId)/$($region)/$($environment)/$($secretsFileName)"
            }
            if (Test-Path $secretsFilePath) {
                #$secrets = Invoke-KMSDecrypt -CiphertextBlob "fileb://$($secretsFilePath)" -PlainText
                #TODO
            }
        }
        #if [ -n "${secrets[0]}" ]; then
        #    secret_regex='^[A-Za-z0-9_-]+=.+$';
        #    secret_count=1;
        #    for secret_line in "${secrets[@]}"; do
        #    if [[ "${secret_line}" =~ ${secret_regex} ]]; then
        #        var_key="${secret_line%=*}";
        #        var_val="${secret_line##*=}";
        #        eval export TF_VAR_${var_key}="${var_val}";
        #        ((secret_count++));
        #    else
        #        echo "Malformed secret on line ${secret_count} - ignoring";
        #    fi;
        #    done;
        #fi; #TODO

        # Pull down additional dynamic plaintext tfvars file from S3
        # Anti-pattern warning: Your variables should almost always be in source control.
        # There are a very few use cases where you need constant variability in input variables,
        # and even in those cases you should probably pass additional -var parameters to this script
        # from your automation mechanism.
        # Use this feature only if you're sure it's the right pattern for your use case.
        $dynamicFileName="dynamic.tfvars"
        $dynamicFilePath="$(Join-Path build $dynamicFileName)"
        try {
            $dynamicFile = Get-S3Object -BucketName $bucket -Key "$($project)/$($awsAccountId)/$($region)/$($environment)/$($dynamicFileName)" -ErrorAction SilentlyContinue
        }
        catch {

        }
        if ($dynamicFile) {
            New-Item -ItemType Directory -Path build -Force
            try {
                Copy-S3Object -BucketName $dynamicFile.BucketName -Key $dynamicFile.Key -LocalFile $dynamicFileName
            }
            catch {
                Out-Results "S3 dynamic file is present, but inaccessible. Ensure you have permission to read s3://$($bucket)/$($project)/$($awsAccountId)/$($region)/$($environment)/$($dynamicFileName)"
                throw "S3 dynamic file is present, but inaccessible. Ensure you have permission to read s3://$($bucket)/$($project)/$($awsAccountId)/$($region)/$($environment)/$($dynamicFileName)"
            }
        }
        # Use versions TFVAR files if exists
        $script:versionsFileName="versions_$($region)_$($environment).tfvars"
        $script:versionsFilePath="$(Join-Path (Join-Path $basePath etc) $versionsFileName)"

        # Check environment name is a known environment
        # Could potentially support non-existent tfvars, but choosing not to.
        $script:envFilePath="$(Join-Path (Join-Path $($basePath) etc) env_$($region)_$($environment).tfvars)"
        if (!(Test-Path $envFilePath)) {
            Out-Results "Unknown environment. $envFilePath does not exist."
            throw "Unknown environment. $envFilePath does not exist."
        }
        
        # Check for presence of a global variables file, and use it if readable
        $script:globalVarsFileName="global.tfvars"
        $script:globalVarsFilePath="$(Join-Path (Join-Path $basePath etc) $globalVarsFileName)"

        # Check for presence of a region variables file, and use it if readable
        $script:regionVarsFileName="$($region).tfvars"
        $script:regionVarsFilePath="$(Join-Path (Join-Path $basePath etc) $regionVarsFilename)"

        # Check for presence of a group variables file if specified, and use it if readable
        if ($group) {
            $groupVarsFileName="group_$($group).tfvars"
            $groupVarsFilepath="$(Join-Path (Join-Path $basePath etc) $groupVarsFileName)"
        }
            

        # Collect the paths of the variables files to use
        $script:tfVarFilePaths = @()

        # Use Global and Region first, to allow potential for terraform to do the
        # honourable thing and override global and region settings with environment
        # specific ones; however we do not officially support the same variable
        # being declared in multiple locations, and we warn when we find any duplicates
        if (Test-Path $globalVarsFilepath) {
            $script:tfVarFilePaths+=$globalVarsFilepath
        }
        if (Test-Path $regionVarsFilepath) {
            $script:tfVarFilePaths+=$regionVarsFilepath
        }
        # If a group has been specified, load the vars for the group. If we are to assume
        # terraform correctly handles override-ordering (which to be fair we don't hence
        # the warning about duplicate variables below) we add this to the list after
        # global and region-global variables, but before the environment variables
        # so that the environment can explicitly override variables defined in the group.
        if ($group) {
            if (Test-Path $groupVarsFilepath) {
                $script:tfVarFilePaths+=$groupVarsFilepath
            } else {
                Out-Results "[WARNING] Group `"$group`" has been specified, but no group variables file is available at $($groupVarsFilepath)"
            }
        }
        # We've already checked this is readable and its presence is mandatory
        $script:tfVarFilePaths+=$envFilePath

        # If present and readable, use versions and dynamic variables too
        if (Test-Path $versionsFilePath) {
            $script:tfVarFilePaths+=$versionsFilePath
        }
        if (Test-Path $dynamicFilePath) {
            $script:tfVarFilePaths+=$dynamicFilePath
        }
        
        # Warn on duplication
        #$duplicateVariables 
        #duplicate_variables="$(cat "${tfVarFilePaths[@]}" | sed -n -e 's/\(^[a-zA-Z0-9_\-]\+\)\s*=.*$/\1/p' | sort | uniq -d)";
        #[ -n "${duplicate_variables}" ] \
        #  && echo -e "
###################################################################
# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING #
###################################################################
#The following input variables appear to be duplicated:
#
#${duplicate_variables}
#
#This could lead to unexpected behaviour. Overriding of variables
#has previously been unpredictable and is not currently supported,
#but it may work.
#
#Recent changes to terraform might give you useful overriding and
#map-merging functionality, please use with caution and report back
#on your successes & failures.
###################################################################";
        # TODO

        # Build up the tfvars arguments for terraform command line
        foreach ($filePath in $tfVarFilePaths) {
            $script:tfVarParams+="-var-file=`"$filePath`""
        }
    }
}

function Out-Usage {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    Out-Results "Usage: ${0} \\
    -a/--action        [action] \\
    -b/--bucket-prefix [bucket_prefix] \\
    -c/--component    [componentName \buildId--environment   [environment] \
    $-g/FgroR     K  [grup]
    -i/--build-id      [buildId] (optional) \\
    -p/--project       [project] \\
    -r/--region        [region] \\
    -- \\
    <additional arguments to forward to the terraform binary call>
  
  action:
   - Special actions:
      * plan / plan-destroy
      * apply / destroy
      * graph
      * taint / untaint
  - Generic actions:
      * See https://www.terraform.io/docs/commands/
  
  bucket_prefix (optional):
   Defaults to: "\${project_name}-terraformscaffold"
   - myproject-terraform
   - terraform-yourproject
   - my-first-terraformscaffold-project
  
  buildId (optional):
   - testing
   - \$BUILD_ID (jenkins)
    componentName
 buildIdthe name of the terraform component module in the components director
$  
FenvRonmenK
   -dev
   - test
   - prod
   - management
  
  group:
   - dev
   - live
   - mytestgroup
  
  project:
   - The name of the project being deployed
  
  region (optional):
   Defaults to value of \$AWS_DEFAULT_REGION
   - the AWS region name unique to all components and terraform processes
  
  additional arguments:
   Any arguments provided after "--" will be passed directly to terraform as its own arguments
  "
    
}

function Invoke-Actions {
    Out-Results "______________________________________________________"
    Out-Results "Running $($MyInvocation.MyCommand.Name) at $(Get-Date)" 
    Out-Results "______________________________________________________"
    
    ##
    # Start Doing Real Things
    ##

    # Really Hashicorp? Really?!
    #
    # In order to work with terraform >=0.9.2 (I say 0.9.2 because 0.9 prior
    # to 0.9.2 is barely usable due to key bugs and missing features)
    # we now need to do some ugly things to our terraform remote backend configuration.
    # The long term hope is that they will fix this, and maybe remove the need for it
    # altogether by supporting interpolation in the backend config stanza.
    #
    # For now we're left with this garbage, and no more support for <0.9.0.
    if (Test-Path backend_terraformscaffold.tf) {
        Out-Results "WARNING: backend_terraformscaffold.tf exists and will be overwritten!"
    }
    
    if ($bootstrap) {
        $backendPrefix="$($project)/$($awsAccountId)/$($region)/bootstrap"
        $backendFileName="bootstrap.tfstate"
    } else {
        $backendPrefix="$($project)/$($awsAccountId)/$($region)/$($environment)"
        $backendFileName="$($ComponentName).tfstate"
    }
    $backendKey = "$($backendPrefix)/$($backendFileName)"
    $backendConfig = "terraform {
  backend `"s3`" {
    region = `"$($region)`"
    bucket = `"$($bucket)`"
    key    = `"$($backendKey)`"
    }
}"

    # We're now all ready to go. All that's left is to:
    #   * Write the backend config
    #   * terraform init
    #   * terraform ${action}
    #
    # But if we're dealing with the special bootstrap component
    # we can't remotely store the backend until we've bootstrapped it
    #
    # So IF the S3 bucket already exists, we will continue as normal
    # because we want to be able to manage changes to an existing
    # bootstrap bucket. But if it *doesn't* exist, then we need to be
    # able to plan and apply it with a local state, and *then* configure
    # the remote state.

    # In default operations we assume we are already bootstrapped
    $bootstrapped=$true
    # If we are in bootstrap mode, we need to know if we have already bootstrapped
    # or we are working with or modifying an existing bootstrap bucket
    if ($bootstrap){
        # For this exist check we could do many things, but we explicitly perform
        # an ls against the key we will be working with so as to not require
        # permissions to, for example, list all buckets, or the bucket root keyspace
        try {
            $bootstrapFile = Get-S3Object -BucketName $bucket -key $backendPrefix/$backendFileName
        }
        catch {

        }
        if (!($bootstrapFile)) {
            $bootstrapped = $false
        }
    }
    if ($bootstrapped) {
        try {
            "$($backendConfig)" | Out-File -FilePath backend_terraformscaffold.tf -Force -Encoding ASCII
        }
        catch {
            Out-Results "Failed to write backend config to $(Join-Path (Get-Location) backend_terraformscaffold.tf)"
            throw "Failed to write backend config to $(Join-Path (Get-Location) backend_terraformscaffold.tf)"
        }
        # Nix the horrible hack on exit 
        trap {
            Clear-Mess
        }

        # Configure remote state storage
        Out-Results "Setting up S3 remote state from s3://$($bucket)/$($backendKey)"
        # TODO: Add -upgrade to init when we drop support for <0.10
        try {
            terraform init -force-copy
        }
        catch {
            Out-Results "Terraform init failed"
            throw "Terraform init failed"
        }
    } else {
        # We are bootstrapping. Download the providers, skip the backend config.
        try {
            terraform init -backend=false
        }
        catch {
            Out-Results "Terraform init failed"
            throw "Terraform init failed"
        }
    }    

    switch ($action) {
        "plan" {
            if ($buildId) {
                New-Item -ItemType Directory -Path build -Force
                $planFileName="$($componentName)_$($buildId).tfplan"
                $planFileRemoteKey="$($backendPrefix)/plans/$($planFileName)"
                $out="-out=build/$($planFileName)"
            }

            Out-Results "Running:"
            Out-Results "
            terraform $action `
            -input=false `
            $($refresh) `
            -module-depth=-1 `
            $($tfVarParams) `
            $($extraArgs) `
            $($destroy) `
            $($out)"
            
            terraform $action `
            -input=false `
            $refresh `
            -module-depth=-1 `
            $tfVarParams `
            $extraArgs `
            $destroy `
            $out


            if ($buildId) {
                try{
                    Write-S3Object -LocalFile "$(Join-Path build $planFileName)" -BucketName $bucket -Key $planFileRemoteKey
                }
                catch {
                    Out-Results "Plan file upload to S3 failed (s3://$($bucket)/$($planFileRemoteKey)"
                    throw "Plan file upload to S3 failed (s3://$($bucket)/$($planFileRemoteKey)"
                }
                exit $status
            }
        }
        "graph" {
            try {
                New-Item -ItemType Directory -Path build -Force
            }
            catch {
                Out-Results "Failed to create output directory `"$(Join-Path (Get-Location ) build)`""
                throw "Failed to create output directory `"$(Join-Path (Get-Location ) build)`""
            }
            try {
                #terraform graph -draw-cycles | dot -Tpng > build/${project}-${awsAccountId}-${region}-${environment}.png \
                #TODO Need dot software
                throw
            }
            catch {
                Out-Results "Terraform simple graph generation failed"
                throw "Terraform simple graph generation failed"
            }
            try {
                terraform graph -draw-cycles -verbose | dot -Tpng > build/${project}-${awsAccountId}-${region}-${environment}-verbose.png \
                #TODO Need dot software
                throw
            }
            catch {
                Out-Results "Terraform simple graph generation failed"
                throw "Terraform simple graph generation failed"
            }
            exit 0;
        }
        {"apply","destroy" -contains $_} {
            $extraArgs+="-auto-approve=true"
            if ($buildId)    {
                New-Item -ItemType Directory -Path build -Force
                $planFileName="$($componentName)_$($buildId).tfplan"
                $planFileRemoteKey="$($backendPrefix)/plans/$($planFileName)"
                try{
                    Copy-S3Object -BucketName $bucket -Key $planFileRemoteKey -LocalFile $(Join-Path build $planFileName)
                }
                catch {
                    Out-Results "Plan file download from S3 failed (s3://$($bucket)/$($planFileRemoteKey)"
                    throw "Plan file download from S3 failed (s3://$($bucket)/$($planFileRemoteKey)"
                }
                $apply_plan="build/$($planFileName)"

                Out-Results "Running:
                terraform $($action) `
                -input=false `
                $($refresh) `
                -parallelism=10 `
                $($extraArgs) `
                $($force) `
                $($apply_plan) `
                "

                terraform $action `
                -input=false `
                $refresh `
                -parallelism=10 `
                $extraArgs `
                $force `
                $apply_plan `

                $exitCode=$LASTEXITCODE
            } else {
                Out-Results "Running:
                terraform $($action) `
                -input=false `
                $($refresh) `
                $($tfVarParams) `
                -parallelism=10 `
                $($extraArgs) `
                $($force)
                "

                terraform "$($action)" `
                -input=false `
                $refresh `
                $tfVarParams `
                -parallelism=10 `
                $extraArgs `
                $force

                $exitCode=$LASTEXITCODE

                if (!($bootstrapped)) {
                    # If we are here, and we are in bootstrap mode, and not already bootstrapped,
                    # Then we have just bootstrapped for the first time! Congratulations.
                    # Now we need to copy our state file into the bootstrap bucket
                    try {
                        "$($backendConfig)" | Out-File backend_terraformscaffold.tf -Force -Encoding ASCII
                    }
                    catch {
                        Out-Results "Failed to write backend config to $((Join-Path (Get-Location) backend_terraformscaffold.tf))"
                        throw "Failed to write backend config to $((Join-Path (Get-Location) backend_terraformscaffold.tf))"
                    }
                    # Nix the horrible hack on exit
                    trap {
                        Clear-Mess
                    }
                    # Push Terraform Remote State to S3
                    # TODO: Add -upgrade to init when we drop support for <0.10
                    try {
                        terraform init
                    }
                    catch {
                        Out-Results "Terraform init failed"
                        throw "Terraform init failed"
                    }
                    # Hard cleanup
                    Remove-Item -Force backend_terraformscaffold.tf
                    Remove-Item -Force terraform.tfstate # Prime not the backup
                    Remove-Item -Force .terraform

                    # This doesn't mean anything here, we're just celebrating!
                    bootstrapped=$true
                }
            }
            if ($exitCode -ne 0) {
                Out-Results "Terraform $($action) failed with exit code ${$exitCode}"
                throw "Terraform $($action) failed with exit code ${$exitCode}"
            }
            if (Test-Path "post_apply.sh") {
                #TODO
                #bash post_apply.sh "${region}" "${environment}" "${action}";
                Out-Results "The PowerShell version of Scaffold does not support Post-Apply scripts yet"
                throw "The PowerShell version of Scaffold does not support Post-Apply scripts yet"
            }
        }
        "*taint" {
            try {
                Out-Results "Running:
                terraform `"$($action) $($extraArgs)`"
                "
                terraform "$($action) $($extraArgs)"
            }
            catch {
                Out-Results "Terraform $($action) failed."
                throw "Terraform $($action) failed."
            }
            
        }
        "import" {
            try {
                terraform "$($action) $($tfVarParams) $($extraArgs)"
            }
            catch {
                Out-Results "Terraform $($action) failed."
                throw "Terraform $($action) failed."
            }
        }
        default {
            Out-Results "Generic action case invoked. Only the additional arguments will be passed to terraform, you break it you fix it:"
            Out-Results "terraform $($action) $($extraArgs)"
            try {
                terraform "$($action)" $extraArgs
            }
            catch {
                Out-Results "Terraform $($action) failed."
                throw "Terraform $($action) failed."
            }
        }
    }
}

Out-Results
New-ScriptInitialization
Convert-Variables
Out-Parameters
Set-Credentials
Set-Variables
Set-TerraformOptions
Build-Parameters
Invoke-Actions
Clear-Mess
