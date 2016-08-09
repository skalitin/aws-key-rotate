Import-Module AWSPowerShell

$profile = 'default'
$region = 'us-east-1'

$credentials = Get-AWSCredentials -ProfileName $profile
$accessKey = ($credentials.GetCredentials()).AccessKey
Write-Output "Current access key: $accessKey"

#Remove access keys except current one
$keysToRemove = Get-IAMAccessKey | Select-Object -ExpandProperty AccessKeyId | ?{ $_ -ne $accessKey }

Write-Output "Removing key(s), if any: $keysToRemove..."
$keysToRemove | %{ Remove-IAMAccessKey -AccessKeyId $_ -Force }

Write-Output "Creating new access key..."
$newKey = New-IAMAccessKey

if ($newKey)
{
    Write-Output "Removing current key..."
    Remove-IAMAccessKey -AccessKeyId $accessKey -Force

    Write-Output "Saving access key $($newKey.AccessKeyId)..."
    Set-AWSCredentials -AccessKey $newKey.AccessKeyId -SecretKey $newKey.SecretAccessKey -StoreAs $profile
    Initialize-AWSDefaults -StoredCredentials $profile -Region $region
}