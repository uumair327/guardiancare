# Script to fix lint issues in Firebase adapters

# Fix catch clauses - change "} catch (e, st) {" to "} on Exception catch (e, st) {"
$files = @(
    "lib\core\backend\adapters\firebase\firebase_analytics_adapter.dart",
    "lib\core\backend\adapters\firebase\firebase_auth_adapter.dart",
    "lib\core\backend\adapters\firebase\firebase_data_store_adapter.dart",
    "lib\core\backend\adapters\firebase\firebase_storage_adapter.dart",
    "lib\core\backend\adapters\firebase\firebase_realtime_adapter.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $content = $content -replace '(\s+)\} catch \(e, st\) \{', '$1} on Exception catch (e, st) {'
        $content = $content -replace '(\s+)\} catch \(e\) \{', '$1} on Exception catch (e) {'
        Set-Content $file $content -NoNewline
        Write-Host "Fixed: $file"
    }
}

Write-Host "Done fixing catch clauses!"
