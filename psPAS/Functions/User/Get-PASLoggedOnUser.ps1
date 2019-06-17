﻿function Get-PASLoggedOnUser {
	<#
.SYNOPSIS
Returns details of the logged on user

.DESCRIPTION
Returns information on the user who is logged in.

.EXAMPLE
Get-PASLoggedOnUser

Returns information on the user associated with the authorisation token.

.INPUTS
All parameters can be piped by property name

.OUTPUTS
Outputs Object of Custom Type psPAS.CyberArk.Vault.User
Output format is defined via psPAS.Format.ps1xml.
To force all output to be shown, pipe to Select-Object *
#>
	[CmdletBinding()]
	param(

	)

	BEGIN { }#begin

	PROCESS {

		#Create URL for request
		$URI = "$Script:BaseURI/WebServices/PIMServices.svc/User"

		#send request to web service
		$result = Invoke-PASRestMethod -Uri $URI -Method GET -WebSession $Script:WebSession

		if ($result) {

			$result | Add-ObjectDetail -typename psPAS.CyberArk.Vault.User

		}

	}#process

	END { }#end

}