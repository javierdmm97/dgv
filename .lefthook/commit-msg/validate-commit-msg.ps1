# Validate commit message format
$commitMsg = Get-Content .git/COMMIT_EDITMSG -Raw

# Regex for conventional commits
$pattern = "^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,100}"

if ($commitMsg -notmatch $pattern) {
    Write-Host ""
    Write-Host "❌ Invalid commit message format!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Commit message must follow the format:" -ForegroundColor Yellow
    Write-Host "  type(scope): description"
    Write-Host ""
    Write-Host "Types:" -ForegroundColor Yellow
    Write-Host "  feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  feat(breathalyzer): add OCR camera screen"
    Write-Host "  fix(scoring): correct points deduction formula"
    Write-Host "  docs(readme): update installation instructions"
    Write-Host ""
    exit 1
}

Write-Host "✅ Commit message format is valid" -ForegroundColor Green
exit 0
