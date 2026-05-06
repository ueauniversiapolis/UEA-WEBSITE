# Script pour publier le site UEA sur GitHub Pages
Write-Host "🚀 Publication du site UEA sur GitHub Pages" -ForegroundColor Green
Write-Host ""

# Demander les informations GitHub
$username = Read-Host "Entrez votre nom d'utilisateur GitHub"
$token = Read-Host "Entrez votre Personal Access Token GitHub (créé dans Settings > Developer settings > Personal access tokens)"

if (-not $username -or -not $token) {
    Write-Host "❌ Informations manquantes. Veuillez réessayer." -ForegroundColor Red
    exit
}

# Configuration
$repoName = "UEA-WEBSITE"
$apiUrl = "https://api.github.com"
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-GitHub-Uploader"
}

Write-Host "📝 Création du repository..." -ForegroundColor Yellow

# Créer le repository
$repoData = @{
    name = $repoName
    description = "Site officiel de l'Union Étudiante Africaine - Universiapolis Agadir"
    private = $false
    has_issues = $true
    has_projects = $true
    has_wiki = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/user/repos" -Method Post -Headers $headers -Body $repoData
    Write-Host "✅ Repository '$repoName' créé avec succès !" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "⚠️  Le repository '$repoName' existe déjà. Continuons avec l'upload..." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur lors de la création du repository: $($_.Exception.Message)" -ForegroundColor Red
        exit
    }
}

Write-Host "📤 Upload du fichier HTML..." -ForegroundColor Yellow

# Lire le contenu du fichier
$filePath = "index_clean.html"
if (-not (Test-Path $filePath)) {
    Write-Host "❌ Fichier '$filePath' introuvable !" -ForegroundColor Red
    exit
}

$content = Get-Content $filePath -Raw -Encoding UTF8
$encodedContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))

# Uploader le fichier
$fileData = @{
    message = "Ajout du site web UEA"
    content = $encodedContent
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/repos/$username/$repoName/contents/index.html" -Method Put -Headers $headers -Body $fileData
    Write-Host "✅ Fichier uploadé avec succès !" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'upload: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "⚙️  Activation de GitHub Pages..." -ForegroundColor Yellow

# Activer GitHub Pages
$pagesData = @{
    source = @{
        branch = "main"
        path = "/"
    }
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/repos/$username/$repoName/pages" -Method Post -Headers $headers -Body $pagesData
    Write-Host "✅ GitHub Pages activé !" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "⚠️  GitHub Pages est déjà activé ou en cours d'activation." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur lors de l'activation de GitHub Pages: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Publication terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Votre site sera accessible dans quelques minutes à :" -ForegroundColor Cyan
Write-Host "   https://$username.github.io/$repoName" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "📋 Instructions supplémentaires :" -ForegroundColor Yellow
Write-Host "   - Si le site ne s'affiche pas immédiatement, patientez 2-3 minutes"
Write-Host "   - Pour un domaine personnalisé, allez dans Settings > Pages de votre repository"
Write-Host "   - Pour mettre à jour le site, modifiez le fichier et uploadez-le à nouveau"
Write-Host ""
Write-Host "💡 Conseil : Gardez votre Personal Access Token en sécurité !" -ForegroundColor Magenta