# Connect to Microsoft Graph
#Connect-MgGraph -Scopes "User.ReadWrite.All"

# List of UserPrincipalNames to exclude from deletion
$excludeAccounts = @(
    "admin@itpw.in",
    "aks@itpw.in"
)

# Retrieve all users in the tenant
$allUsers = Get-MgUser -All

foreach ($user in $allUsers) {
    if ($excludeAccounts -notcontains $user.UserPrincipalName) {
        try {
            Remove-MgUser -UserId $user.UserPrincipalName
            Write-Host "Deleted user: $($user.UserPrincipalName)"
        } catch {
            Write-Host "Failed to delete user: $($user.UserPrincipalName). Error: $_"
        }
    } else {
        Write-Host "Skipping user: $($user.UserPrincipalName)"
    }
}
