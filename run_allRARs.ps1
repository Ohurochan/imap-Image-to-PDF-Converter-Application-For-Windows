# RARファイルがあるディレクトリ
$rarDir = "C:\Downloads\test\rar"

# 解凍先ディレクトリ
$extractDir = "C:\Downloads\test\images"

# PDFの保存先ディレクトリ（初期値）
$pdfSaveDir = "C:\Downloads\test\pdf\export"

# 7-Zipのパス（環境に合わせて変更）
$sevenZipPath = "C:\pgfiles\7-Zip\7z.exe"

# RARファイルの処理
$rarFiles = Get-ChildItem -Path $rarDir -Filter "*.rar"
foreach ($rarFile in $rarFiles) {
    $rarFileName = [System.IO.Path]::GetFileNameWithoutExtension($rarFile.Name)
    $rarFilePath = Join-Path $rarDir $rarFileName
    $currentExtractPath = Join-Path $extractDir $rarFileName

    Write-Output "[DEBUG] Unpacking parent rar: `"$rarFilePath`""

    # 解凍先ディレクトリを作成
    if (!(Test-Path $currentExtractPath)) {
        New-Item -ItemType Directory -Path $currentExtractPath | Out-Null
    }

    # 7-ZipでRARを解凍
    & "$sevenZipPath" x "`"$rarFilePath.rar`"" "-o`"$currentExtractPath`"" -y

    # 子RARファイルの処理
    $rarChildsFiles = Get-ChildItem -Path $currentExtractPath -Filter "*.rar"
    foreach ($rarChild in $rarChildsFiles) {
        $rarChildName = [System.IO.Path]::GetFileNameWithoutExtension($rarChild.Name)
        $childExtractPath = Join-Path $currentExtractPath $rarChildName
        Write-Output "[DEBUG] making child outDir:childExtractPath: `"$childExtractPath`""
 
        # 7-ZipでRARを解凍
        $rarChildPath = Join-Path $currentExtractPath $rarChild
        Write-Output "[DEBUG] Unpacking child rar: `"$rarChild`""
        & "$sevenZipPath" x "`"$rarChildPath`"" "-o`"$childExtractPath`"" -y
    }

    # 画像が含まれる親ディレクトリを設定
    $parentDir = $currentExtractPath

    # フォルダ名を適切にエスケープして渡す
    Get-ChildItem -Path $parentDir -Directory | ForEach-Object {
        $folderPath = $_.FullName
        $pdfFileName = $_.Name + ".pdf"  # 子ディレクトリ名をPDFファイル名に設定
        Write-Output "[DEBUG] creating pdf:folderPath   : `"$folderPath`""
        Write-Output "[DEBUG] creating pdf:pdfFileName  : `"$pdfFileName`""

        python .\cui_main.py "`"$folderPath`"" "`"$pdfFileName`"" "`"$pdfSaveDir`""
    }

    # PDF保存ディレクトリの名前を変更
    Rename-Item -Path $pdfSaveDir -NewName $rarFileName -Force

}

Write-Output "done"
