# Connect with privileges
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Get properties
$Properties = @(
    'Id',
    'userPrincipalName',
    'displayName',
    'deletedDateTime',
    'userType'
)

# Retrieve deleted directory items
$DeletedItems = Get-MgDirectoryDeletedItemAsUser -All -Property $Properties | Select-Object $Properties

# Check if there are no deleted accounts
if ($DeletedItems.Count -eq 0) {
    Write-Host "No deleted accounts found in the recycle bin." -ForegroundColor Cyan
} else {
    # Create an array to store the report
    $Report = @()

    # Loop through the deleted items
    foreach ($Item in $DeletedItems) {
        $DeletedDate = Get-Date($Item.DeletedDateTime)
        $DaysSinceDeletion = (New-TimeSpan -Start $DeletedDate).Days

        # Create a custom object for each item and add it to the report
        $ReportLine = [PSCustomObject]@{
            Id                    = $Item.Id
            UserPrincipalName     = $Item.UserPrincipalName
            'Display Name'        = $Item.DisplayName
            Deleted               = $DeletedDate
            'Days Since Deletion' = $DaysSinceDeletion
            Type                  = $Item.UserType
        }
        $Report += $ReportLine

        # Permanently delete the item
        Remove-MgDirectoryDeletedItem -DirectoryObjectId $Item.Id
        Write-Host "Permanently deleted item with ID $($Item.Id)" -ForegroundColor Green
    }

    # Sort the report by 'Display Name'
    $Report | Sort-Object 'Display Name' | Format-Table
}
