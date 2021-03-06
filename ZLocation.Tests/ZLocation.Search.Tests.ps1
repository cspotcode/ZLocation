Import-Module $PSScriptRoot\..\ZLocation\ZLocation.Search.psm1 -Force

Describe 'Find-Matches filters results correctly' {
    Context 'Equal weight' {
        $data = @{
            'C:\foo1\foo2\foo3' = 1.0
            'C:\foo1\foo2' = 1.0
            'C:\foo1' = 1.0
            'C:\' = 1.0
        }

        It 'Does not modify data' {
            Find-Matches $data fuuuu
            $data.Count | Should be 4
        }

        It 'returns only leave result' {
            Find-Matches $data foo2 | Should Be 'C:\foo1\foo2'
        }

        It 'returns multiply results' {
            (Find-Matches $data foo | measure).Count | Should Be 3
        }

        It 'should be case-insensitive' {
            Find-Matches $data FoO1 | Should Be 'C:\foo1'
        }

        It 'returns disk root folder for C:' {
            Find-Matches $data C: | Should Be 'C:\'
        }

        It 'returns disk root folder for C' {
            Find-Matches $data C | Should Be 'C:\'
        }

        It 'should ignore trailing \' {
            Find-Matches $data C:\foo1\ | Should Be 'C:\foo1'
        }
    }

    Context 'Different weight' {
        $data = @{
            'C:\admin' = 1.0
            'C:\admin\monad' = 2.0
        }

        It 'Use leaf matches' {
            Find-Matches $data 'adm' | Should Be 'C:\admin'
        }
    }
}
