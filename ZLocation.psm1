﻿Set-StrictMode -Version Latest

#
# You can customize this logic to tweak weight function.
#
function Update-ZLocation([string]$path)
{
    $now = [datetime]::Now
    if (Test-Path variable:global:__zlocation_current)
    {
        $prev = $global:__zlocation_current
        $weight = $now.Subtract($prev.Time).TotalSeconds
        Add-ZWeight ($prev.Location) $weight 
    }

    $global:__zlocation_current = @{
        Location = $path
        Time = [datetime]::Now
    }
}

(Get-Variable pwd).attributes.Add((new-object ValidateScript { Update-ZLocation $_.Path; return $true }))
#
# End of weight function logic.
#


#
# Querying logic. You can customize it.
#
function Find-Matches([hashtable]$hash, [string[]]$query)
{
    foreach ($key in ($hash.GetEnumerator().Name)) 
    {
        if (-not (Test-FuzzyMatch $key $query)) 
        {
            $hash.Remove($key)
        }
    }
    $res = $hash.GetEnumerator() | sort -Property Value
    if ($res) {
        $res | %{$_.Name}
    }
}

function Test-FuzzyMatch([string]$path, [string[]]$query)
{
    $n = $query.Length
    for ($i=0; $i -le $n-1; $i++)
    {
        if (-not ($path -match $query[$i]))
        {
            return $false
        }
    }   
    
    $leaf = Split-Path -Leaf $path
    return ($path -match $query[$n-1]) 
}
#
# End of querying logic.
#

function Set-ZLocation()
{
    $matches = Find-Matches (Get-ZLocation) $args
    if ($matches) {
        Push-Location ($matches | Select-Object -First 1)
    } else {
        Write-Warning "Cannot find mathing location"
    }
}

Set-Alias -Name z -Value Set-ZLocation

Export-ModuleMember -Function Set-ZLocation -Alias z