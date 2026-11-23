Set-Location (Join-Path $PSScriptRoot '..')
Remove-Item pubget.done, pubget.log -ErrorAction SilentlyContinue
foreach ($i in 1..40) {
  "attempt $i $(Get-Date)" | Add-Content pubget.log
  flutter pub get *>> pubget.log
  if ($LASTEXITCODE -eq 0) { 'done' | Set-Content pubget.done; break }
  Start-Sleep -Seconds 10
}
