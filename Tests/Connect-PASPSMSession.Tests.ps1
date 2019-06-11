#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get Function Name
$FunctionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Assume ModuleName from Repository Root folder
$ModuleName = Split-Path (Split-Path $Here -Parent) -Leaf

#Resolve Path to Module Directory
$ModulePath = Resolve-Path "$Here\..\$ModuleName"

#Define Path to Module Manifest
$ManifestPath = Join-Path "$ModulePath" "$ModuleName.psd1"

if ( -not (Get-Module -Name $ModuleName -All)) {

	Import-Module -Name "$ManifestPath" -ArgumentList $true -Force -ErrorAction Stop

}

BeforeAll {

	$Script:RequestBody = $null

}

AfterAll {

	$Script:RequestBody = $null

}

Describe $FunctionName {

	InModuleScope $ModuleName {

		Mock Invoke-PASRestMethod -MockWith {
			[PSCustomObject]@{"Prop1" = "VAL1"; "Prop2" = "Val2"; "Prop3" = "Val3" }
		}

		$InputObj = [pscustomobject]@{
			"SessionId"        = "SomeSession"
			"ConnectionMethod" = "RDP"

		}

		Context "Mandatory Parameters" {

			$Parameters = @{Parameter = 'SessionId' },
			@{Parameter = 'ConnectionMethod' }

			It "specifies parameter <Parameter> as mandatory" -TestCases $Parameters {

				param($Parameter)

				(Get-Command Connect-PASPSMSession).Parameters["$Parameter"].Attributes.Mandatory | Select-Object -Unique | Should Be $true

			}

		}

		$response = $InputObj | Connect-PASPSMSession -ConnectionMethod RDP

		Context "Input" {

			It "sends request" {

				Assert-MockCalled Invoke-PASRestMethod -Times 1 -Exactly -Scope Describe

			}

			It "sends request to expected endpoint for PSMConnect" {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

					$URI -eq "$($InputObj.BaseURI)/$($InputObj.PVWAAppName)/API/LiveSessions/SomeSession/monitor"

				} -Times 1 -Exactly -Scope Describe

			}

			It "uses expected method" {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter { $Method -match 'GET' } -Times 1 -Exactly -Scope Describe

			}

			It "sends request with no body" {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

					$Body -eq $null

				} -Times 1 -Exactly -Scope Describe

			}

			It "has expected Accept key in header" {

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

					$Headers["Accept"] -eq 'application/json' } -Times 1 -Exactly -Scope Describe

			}

			It "specifies expected Accept key in header for PSMGW requests" {

				$InputObj | Connect-PASPSMSession -ConnectionMethod PSMGW

				Assert-MockCalled Invoke-PASRestMethod -ParameterFilter {

					$Headers["Accept"] -eq '* / *' } -Times 1 -Exactly -Scope It

			}

			It "throws error if version requirement not met" {
				{ $InputObj | Connect-PASPSMSession -ConnectionMethod RDP -ExternalVersion "9.8" } | Should Throw
			}

		}

		Context "Output" {

			it "provides output" {

				$response | Should not BeNullOrEmpty

			}

			It "has output with expected number of properties" {

				($response | Get-Member -MemberType NoteProperty).length | Should Be 3

			}

			it "outputs object with expected typename" {

				$response | get-member | select-object -expandproperty typename -Unique | Should Be System.Management.Automation.PSCustomObject

			}



		}

	}

}