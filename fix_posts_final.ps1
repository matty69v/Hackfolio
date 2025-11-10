# Script pour nettoyer les posts et fixer les chemins d'images

$postsFolder = "C:\Users\bezet\OneDrive - INSTITUTION CHARTREUX\TryHackMe\_posts"

Get-ChildItem -Path $postsFolder -Filter "*.md" | ForEach-Object {
    $filePath = $_.FullName
    $fileName = $_.Name
    
    # Extraire le slug du nom de fichier
    if ($fileName -match '\d{4}-\d{2}-\d{2}-tryhackme-(.+)\.md') {
        $slug = $matches[1]
        
        # Lire le contenu
        $content = Get-Content -Path $filePath -Raw
        
        $modified = $false
        
        # 1. Supprimer les dates dupliquées après le frontmatter
        if ($content -match '---\n\ndate:') {
            $content = $content -replace '\n\ndate:[^\n]+\n', "`n`n"
            $modified = $true
        }
        
        # 2. Fixer le chemin de l'image dans le frontmatter
        if ($content -match 'image:\s*\n\s*path:\s*([^\n/]+\.webp)') {
            $imageFile = $matches[1]
            $newImagePath = "/images/tryhackme_$slug/$imageFile"
            $content = $content -replace '(image:\s*\n\s*path:\s*)([^\n/]+\.webp)', "`$1$newImagePath"
            $modified = $true
        }
        
        if ($modified) {
            # Écrire le contenu modifié
            Set-Content -Path $filePath -Value $content -NoNewline -Encoding UTF8
            Write-Host "✅ Nettoyé: $fileName" -ForegroundColor Green
        } else {
            Write-Host "⏭️  Déjà correct: $fileName" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✨ Nettoyage terminé !" -ForegroundColor Cyan
