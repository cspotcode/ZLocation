# This is integration tests.

# -Force re-import nested modules as well
#Import-Module $PSScriptRoot\..\ZLocation\ZLocation.Storage.psm1 -Force
#Import-Module $PSScriptRoot\..\ZLocation\ZLocation.Search.psm1 -Force
Import-Module $PSScriptRoot\..\ZLocation\ZLocation.psm1 -Force

Describe 'ZLocation' {

    Context 'Success scenario' {

        It 'can execute scenario with new directory' {
            try {
                $newdirectory = [guid]::NewGuid().Guid
                $curDirFullPath = ($pwd).Path
                mkdir $newdirectory
                cd $newdirectory
                $newDirFullPath = ($pwd).Path
                # trigger weight update
                prompt > $null
                # go back
                cd $curDirFullPath

                # do the jump
                z ($newdirectory.Substring(0, 3))
                ($pwd).Path | Should Be $newDirFullPath

                # verify that pop-location can be used after z
                z -
                ($pwd).Path | Should Be $curDirFullPath

                $h = Get-ZLocation
                $h[$newDirFullPath] | Should Be 1
            } finally {
                cd $curDirFullPath
                Remove-Item -rec -force $newdirectory
                Remove-ZLocation $newDirFullPath
            }
        }
    }

    InModuleScope ZLocation {
        Context 'Alias matching regex' {
            It 'Should match the full command name' {
                'Set-ZLocation whatever' | Should Match $TabExpansionRegex
            }

            It 'Should match the default "z" alias' {
                'z whatever' | Should Match $TabExpansionRegex
            }
        }
    }
}
