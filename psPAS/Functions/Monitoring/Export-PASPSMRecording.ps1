function Export-PASPSMRecording {
	<#
.SYNOPSIS
Saves a PSM Recording

.DESCRIPTION
Saves a specific recorded session to a file

.PARAMETER RecordingID
Unique ID of the recorded PSM session

.PARAMETER Path
The output file path for the recording.

.EXAMPLE
Export-PASPSMRecording -RecordingID 123_45 -path C:\PSMRecording.avi

Saves PSM Recording with Id 123_45 to C:\PSMRecording.avi

.INPUTS
All parameters can be piped by property name

.OUTPUTS

.NOTES
Minimum CyberArk Version 10.6
#>
	[CmdletBinding()]
	param(
		[parameter(
			Mandatory = $true,
			ValueFromPipelinebyPropertyName = $true
		)]
		[string]$RecordingID,

		[parameter(
			Mandatory = $true,
			ValueFromPipelinebyPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf -IsValid})]
		[string]$path
	)

	BEGIN {
		$MinimumVersion = [System.Version]"10.6"
	}#begin

	PROCESS {

		Assert-VersionRequirement -ExternalVersion $Script:ExternalVersion -RequiredVersion $MinimumVersion

		#Create URL for Request
		$URI = "$Script:BaseURI/API/Recordings/$($RecordingID | Get-EscapedString)/Play"

		#send request to PAS web service
		$result = Invoke-PASRestMethod -Uri $URI -Method POST -WebSession $Script:WebSession

		#if we get a platform byte array
		if($result) {

			try {

				$output = @{
					Path     = $path
					Value    = $result
					Encoding = "Byte"
				}

				If($IsCoreCLR) {

					#amend parameters for splatting if we are in Core
					$output.Add("AsByteStream", $true)
					$output.Remove("Encoding")

				}

				#write it to a file
				Set-Content @output -ErrorAction Stop

			} catch {throw "Error Saving $path"}

		}

	} #process

	END {}#end

}