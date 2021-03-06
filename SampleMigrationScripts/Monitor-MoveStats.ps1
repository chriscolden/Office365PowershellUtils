param( [string]$batchname)
if (!$batchname) {$batchname = "All1"}
#Clear-Host
Get-Date
#Get-MoveRequest -batchname $batchname | Group-Object -Property Status | Tee-Object -Variable MoveStats | FT
Get-MoveRequest | Group-Object -Property Status | Tee-Object -Variable MoveStats | FT
#Write-Host "----------------------------------------------------------------------------------------------------------"
#Write-Host "Failed:"
#($MoveStats | Where-Object {$_.Name -eq 'Failed'}).Group | Group-Object FailureType
Write-Host "----------------------------------------------------------------------------------------------------------"
($MoveStats | Where-Object {$_.Name -eq 'InProgress'}).Group | Get-MoveRequestStatistics | FT
