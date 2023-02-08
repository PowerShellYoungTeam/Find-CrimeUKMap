<#
.Synopsis
   UK Police API
.DESCRIPTION
   Do you like to fight crime? Okay how about do you like to find crime? Well now you can, maybe you want to know how much
   crime is in your area, maybe you looking to move to a new place in the UK but do not know the local crime scene. Maybe
   you a gangster and want to see how little crime there is in a given area to then go cause some mayhem. Well what-ever
   your reasons, you too can now be a crime investigator, by finding crime and the outcome if the police have bothered to
   update it. Finally for me this was amazing to see all the unsolved crime in my area, broken Britain at its best.
.EXAMPLE
   Find-CrimeUK -Town Gosport -Year 2022 -Month 02
.EXAMPLE
   Find-CrimeUK -City Portsmouth -Year 2022 -Month 03
.EXAMPLE
   Find-CrimeUK -LocationName Bridgemary -Year 2020 -Month 01
.NOTES
   Information on crime in the UK from the UK Police API
.COMPONENT
   The component this cmdlet belongs to Adam Bacon
.ROLE
   The role this cmdlet belongs to is the people of the UK to see how bad crime is in your area
.FUNCTIONALITY
   Allows you to easily find the crime in your area of the UK via a location name
#>
function Find-CrimeUKwithMap {
    [CmdletBinding()]
    Param
    (
       [Parameter(Mandatory = $true,
          Position = 0,
          HelpMessage = "Type the location name of interest such as Gosport or maybe a location in Gosport, like Alverstoke. Keep this to a single word"
       )]
       [Alias("Town")]
       [Alias("City")]
       [Alias("Village")]
       [string]$LocationName,
       [Parameter(Mandatory = $true)]
       [ValidateSet("2020", "2021", "2022","2023")]
       [string]$Year,
       [Parameter(Mandatory = $true)]
       [ValidateSet("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")]
       [string]$Month
    )
 
    Begin {
       Write-Verbose -Message "Obtaining the latitude and longitude of the location entered"
       $place = Invoke-RestMethod "https://geocode.maps.co/search?q={$LocationName}"
       if ($place.lat.count -gt 1) {
          $placeLat = $place.lat[0]
          $placeLon = $place.lon[0]
       }
       else {
          $placeLat = $place.lat
          $placeLon = $place.lon
       }
    }
    Process {
       try {
          $crime = Invoke-RestMethod "https://data.police.uk/api/crimes-street/all-crime?lat=$placeLat&lng=$placeLon&date=$Year-$Month" -ErrorAction Stop
                   $Props = @()
          foreach ($item in $crime){
          $Props += [PSCustomObject]@{
          Category = $item.category
          Type = $item.location_type
          Latitude = $item.location | select -ExpandProperty latitude
          Longitude = $item.location | select -ExpandProperty longitude
          Street = ($item.location).street | Select -ExpandProperty name
          Outcome = ($item.outcome_status).category
          OutcomeDate = ($item.outcome_status).date
          Reported = $item.month
          ID = $item.id
          PersistentID = $item.persistent_id
          }
          }
         
        $SelectedProps =  $Props | Out-GridView -PassThru -Title "Crimes Reported - select to view on map" 

        foreach($SelectedProp in $SelectedProps){
            Start-Process microsoft-edge:"https://www.google.com/maps/@$($SelectedProp.Latitude),$($SelectedProp.Longitude),18.25z"   
        }
       }
       catch {
          Write-Warning "Crumbs something went wrong most likely an invalid location name $($_)"
       }
    }
    End {
       Write-Verbose -Message "Script Finished $(Get-Date)"
    }
 }