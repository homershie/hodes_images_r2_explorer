# Complete R2 delete script with pagination support
param(
    [string]$AccountId = "b6df93992d17685bcab2a54a9c9da654",
    [string]$BucketName = "hodes-images"
)

Write-Host "=== Complete R2 Delete Script (with Pagination) ===" -ForegroundColor Green
Write-Host "Account ID: $AccountId" -ForegroundColor Cyan
Write-Host "Bucket Name: $BucketName" -ForegroundColor Cyan

# Check for API Token
$ApiToken = $env:CLOUDFLARE_API_TOKEN
if (-not $ApiToken) {
    Write-Host "Error: CLOUDFLARE_API_TOKEN not found" -ForegroundColor Red
    exit 1
}

Write-Host "Found API Token" -ForegroundColor Green

# Set API endpoint for listing objects
$BaseUrl = "https://api.cloudflare.com/client/v4/accounts/$AccountId/r2/buckets/$BucketName/objects"

# Set request headers
$Headers = @{
    "Authorization" = "Bearer $ApiToken"
    "Content-Type" = "application/json"
}

Write-Host "Getting all objects from bucket (handling pagination)..." -ForegroundColor Yellow

try {
    # Get all objects with pagination
    $AllObjects = @()
    $Cursor = $null
    $PageCount = 0
    $TotalObjects = 0
    
    do {
        $PageCount++
        $Url = $BaseUrl
        if ($Cursor) {
            $Url += "?cursor=$Cursor"
        }
        
        Write-Host "Fetching page $PageCount..." -ForegroundColor Gray
        $Response = Invoke-RestMethod -Uri $Url -Method GET -Headers $Headers
        
        $Objects = $Response.result
        $AllObjects += $Objects
        $TotalObjects += $Objects.Count
        
        Write-Host "  Found $($Objects.Count) objects on page $PageCount (Total so far: $TotalObjects)" -ForegroundColor Gray
        
        # Check if there are more pages
        $IsTruncated = $Response.result_info.is_truncated
        $Cursor = $Response.result_info.cursor
        
        if ($IsTruncated) {
            Write-Host "  More pages available, continuing..." -ForegroundColor Yellow
        }
        
    } while ($IsTruncated -and $Cursor)
    
    Write-Host "`nFound total $TotalObjects objects across $PageCount pages" -ForegroundColor Cyan
    
    if ($TotalObjects -eq 0) {
        Write-Host "Bucket $BucketName is empty!" -ForegroundColor Green
        Write-Host "You can now delete the bucket:" -ForegroundColor Cyan
        Write-Host "npx wrangler r2 bucket delete $BucketName" -ForegroundColor White
        exit 0
    }
    
    # Show first few files with actual data
    Write-Host "`nFirst 5 objects:" -ForegroundColor Yellow
    for ($i = 0; $i -lt [Math]::Min(5, $AllObjects.Count); $i++) {
        $obj = $AllObjects[$i]
        Write-Host "  Key: '$($obj.key)' Size: $($obj.size) bytes" -ForegroundColor White
    }
    
    if ($AllObjects.Count -gt 5) {
        Write-Host "  ... and $($AllObjects.Count - 5) more objects" -ForegroundColor Gray
    }
    
    Write-Host "`nConfirm deletion of ALL $TotalObjects files?" -ForegroundColor Red
    Write-Host "Type 'YES' to continue:" -ForegroundColor Yellow
    $Confirmation = Read-Host
    
    if ($Confirmation -ne "YES") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    # Delete all objects
    $DeletedCount = 0
    $FailedCount = 0
    
    Write-Host "`nStarting deletion of all $TotalObjects objects..." -ForegroundColor Green
    
    foreach ($obj in $AllObjects) {
        if (-not $obj.key) {
            Write-Host "Skipping object with empty key" -ForegroundColor Yellow
            continue
        }
        
        # URL encode the key for the delete endpoint
        $EncodedKey = [System.Web.HttpUtility]::UrlEncode($obj.key)
        $DeleteUrl = "https://api.cloudflare.com/client/v4/accounts/$AccountId/r2/buckets/$BucketName/objects/$EncodedKey"
        
        try {
            $DeleteResponse = Invoke-RestMethod -Uri $DeleteUrl -Method DELETE -Headers $Headers
            $DeletedCount++
            
            if ($DeletedCount % 10 -eq 0 -or $DeletedCount -eq $TotalObjects) {
                Write-Host "Deleted $DeletedCount/$TotalObjects objects" -ForegroundColor Green
            }
            
        } catch {
            $FailedCount++
            Write-Host "Failed to delete $($obj.key): $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Short delay to avoid API rate limits
        Start-Sleep -Milliseconds 50
    }
    
    Write-Host "`n=== Deletion Summary ===" -ForegroundColor Green
    Write-Host "Successfully deleted: $DeletedCount" -ForegroundColor Green
    Write-Host "Failed: $FailedCount" -ForegroundColor Red
    
    if ($FailedCount -eq 0) {
        Write-Host "All objects deleted successfully!" -ForegroundColor Green
        
        # Final verification
        Write-Host "`nPerforming final verification..." -ForegroundColor Yellow
        $VerifyResponse = Invoke-RestMethod -Uri $BaseUrl -Method GET -Headers $Headers
        $RemainingObjects = $VerifyResponse.result
        
        if ($RemainingObjects.Count -eq 0) {
            Write-Host "✅ Bucket is completely empty!" -ForegroundColor Green
            Write-Host "You can now delete the bucket:" -ForegroundColor Cyan
            Write-Host "npx wrangler r2 bucket delete $BucketName" -ForegroundColor White
        } else {
            Write-Host "⚠️  Still $($RemainingObjects.Count) objects remaining" -ForegroundColor Yellow
            Write-Host "You may need to run this script again" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Some objects failed to delete. You may need to run this script again." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $ResponseStream = $_.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($ResponseStream)
        $ResponseText = $Reader.ReadToEnd()
        Write-Host "Response: $ResponseText" -ForegroundColor Red
    }
}
