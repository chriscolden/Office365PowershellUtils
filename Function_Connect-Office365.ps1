﻿<#
See https://technet.microsoft.com/en-us/library/dn568015.aspx
Expects all modules to be imported or available to import on demand
#>
function global:Connect-Office365 {
	[CmdletBinding(SupportsShouldProcess=$false, DefaultParameterSetName="Username")]
	Param(
		[Parameter(Mandatory=$false,ParameterSetName="Username",HelpMessage="Credentials")]
		    [String]$Username,
		[Parameter(Mandatory=$false,ParameterSetName="Credentials",HelpMessage="Credentials")]
		    [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$false,ParameterSetName="CredentialsFile", HelpMessage="Path to credentials")]
		    [String]$CredentialPath,
        [Parameter(Mandatory=$false,HelpMessage="Forces re-connection when already connected.")]
		    [Switch]$Force
	)
    #First, test if already connected
    $existingConnection = $false
    $existingSession = Get-PSSession -Verbose:$false | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} 
    if ($existingSession -ne $null) {
        $existingConnection = $true
    }

    if (!($existingConnection) -or ($Force)) {

        #Prompt for credential if not provided
        if ($CredentialPath) {
            $Credential = Import-PSCredential -Path $CredentialPath
        }
        if ($Username) {
            $Credential = Get-Credential -UserName $Username -Message "Office 365 Credentials"
        }

        if (!$Credential) {
            $Credential = Get-Credential
        }

        #Connect to MSOLService with credential
        Connect-MsolService -Credential $Credential

        #Connect to Exchange Online session and import
        New-Variable -Scope "Global" -Name ExchangeOnlineSession -Value(New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection)
        #$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $ExchangeOnlineSession -AllowClobber

        #Connect to SharePoint if available
        if (Get-Module Microsoft.Online.SharePoint.PowerShell) {
            Connect-SPOService -Credential $Credential
        }

        #Connect to Skype for Business Online
        if (Get-Module SkypeOnlineConnector) {
            New-Variable -Scope "Global" -Name sfboSession -Value(New-CsOnlineSession -Credential $credential)
            Import-PSSession $sfboSession
        }

        #Connect to Security & Compliance Center
        New-Variable -Scope "Global" -Name ccSession -Value(New-PSSession -ConfigurationName SecurityCompliance -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection)
        Import-PSSession $ccSession -Prefix cc
    }
}
#Echo "Function Connect-Office365 loaded"
