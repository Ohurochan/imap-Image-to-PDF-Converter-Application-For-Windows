import argparse
import os
import sys
from PIL import Image

def get_image_files(dir_path):
    """ 指定ディレクトリ内の画像ファイルをリストアップ """
    valid_extensions = ('.png', '.jpg', '.jpeg', '.bmp', '.gif')
    return [os.path.join(dir_path, f) for f in os.listdir(dir_path)
            if f.lower().endswith(valid_extensions) and os.path.isfile(os.path.join(dir_path, f))]

def make_pdf_only_selected(selected_files, file_name, pdf_location):
    """ 選択された画像ファイルをPDFに変換して保存 """
    images_list = []
    for f in selected_files:
        try:
            images_list.append((Image.open(f)).convert('RGB'))
        except IOError:
            print(f"Warning: {f} は画像として開けませんでした。")

    if not images_list:
        print("Error: 画像ファイルが見つかりません。")
        sys.exit(1)

    os.makedirs(pdf_location, exist_ok=True)
    output_path = os.path.join(pdf_location, file_name)
    images_list[0].save(output_path, save_all=True, append_images=images_list[1:])
    print(f"PDFが作成されました: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="画像ファイルをPDFに変換")
    parser.add_argument("dir_path", help="対象ディレクトリのパス")
    parser.add_argument("file_name", help="保存するPDFファイル名")
    parser.add_argument("pdf_location", help="PDFの保存先ディレクトリ")

    args = parser.parse_args()

    # 引数のバリデーション
    if not os.path.isdir(args.dir_path):
        print(f"Error: 指定されたディレクトリが存在しません: {args.dir_path}")
        sys.exit(1)

    if not args.file_name.lower().endswith(".pdf"):
        print("Error: 保存ファイル名は '.pdf' で終わる必要があります。")
        sys.exit(1)

    if not os.path.exists(args.pdf_location):
        os.makedirs(args.pdf_location)

    # 画像ファイルを取得
    selected_files = get_image_files(args.dir_path)

    if not selected_files:
        print("Error: 指定ディレクトリに画像ファイルが見つかりません。")
        sys.exit(1)

    # PDF作成
    make_pdf_only_selected(selected_files, args.file_name, args.pdf_location)

if __name__ == '__main__':
    main()
