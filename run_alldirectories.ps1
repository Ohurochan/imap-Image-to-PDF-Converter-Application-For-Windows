# 画像が含まれる親ディレクトリ
$parentDir = "C:\Downloads\test\images"

# PDFの保存先ディレクトリ
$pdfSaveDir = "C:\Downloads\test\pdf\export"

# フォルダ名を適切にエスケープして渡す
Get-ChildItem -Path $parentDir -Directory | ForEach-Object {
    $folderPath = $_.FullName
    $pdfFileName = $_.Name + ".pdf"  # 子ディレクトリ名をPDFファイル名に設定

    python .\cui_main.py "`"$folderPath`"" "`"$pdfFileName`"" "`"$pdfSaveDir`""
}
