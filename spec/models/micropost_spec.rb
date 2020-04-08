require "rails_helper"

RSpec.describe "Userモデルのテスト", type: :model do
  # ===== 予め用意したテスト用画像の情報を定義
  # ディレクトリ
  let(:test_image_path) { File.join(Rails.root, "spec/fixtures") }
  # 正常系テスト用の画像ファイル名を定義
  let(:jpg_file_name) { "sample.jpg" }
  let(:jpeg_file_name) { "sample.jpeg" }
  let(:png_file_name) { "sample.png" }
  let(:gif_file_name) { "sample.gif" }
  # 異常系テスト用の画像ファイル名を定義
  let(:bmp_file_name) { "sample.bmp" }
  let(:txt_file_name) { "sample.txt" }

  # アップロードした画像が保存されるディレクトリの定義(Publicディレクトリからの相対パス)
  let(:image_save_dir) { "/uploads/micropost/picture" }

  before do
    @user = User.new(
      name: "Tom",
      email: "cacy@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
    @user.save

    @micropost = @user.microposts.build(
      content: "Test message.",
    )
  end

  context "テストデータの事前確認用テスト" do
    it "テストデータを加工していない場合はバリデーションを通過すること" do
      expect(@micropost).to be_valid
    end
  end

  context "バリデーションのテスト" do
    # --- userのテスト
    it "user,user_idがnilの場合はバリデーションエラーとなること" do
      @micropost.user = nil
      expect(@micropost).not_to be_valid

      @micropost.user_id = nil
      expect(@micropost).not_to be_valid
    end

    # --- contentのテスト
    it "本文が140文字(全角、半角区別なし)を超える場合はバリデーションエラーとなること" do
      # 半角141文字はバリデーションエラーとなること
      @micropost.content = "a" * 141
      expect(@micropost).not_to be_valid

      # 全角140文字は許容されること(バイトが判断基準になっていないこと)
      @micropost.content = "あ" * 140
      expect(@micropost).to be_valid

      # 全角141文字はバリデーションエラーとなること
      @micropost.content = "あ" * 141
      expect(@micropost).not_to be_valid
    end

    it "本文がスペース、空文字のみの場合はバリデーションエラーとなること" do
      # 半角スペース
      @micropost.content = " "
      expect(@micropost).not_to be_valid

      # 全角スペース
      @micropost.content = "　"
      expect(@micropost).not_to be_valid

      # 空文字
      @micropost.content = ""
      expect(@micropost).not_to be_valid
    end
  end

  context "その他のテスト" do
    it "許可された拡張子の画像を保存できること" do
      [
        jpg_file_name,
        jpeg_file_name,
        png_file_name,
        gif_file_name,
      ].each do |image_name|
        micropost = @user.microposts.build(content: "Image upload test.")

        # バリデーションエラーが発生してないこと
        image = Rack::Test::UploadedFile.new("#{test_image_path}/#{image_name}")
        micropost.picture = image
        micropost.save
        expect(micropost).to be_valid

        # 画像が保存されていること
        micropost.reload
        expect(micropost.picture.to_s).to eq "#{image_save_dir}/#{micropost.id}/#{image_name}"
      end
    end

    it "許可されていない拡張子の画像がアップロードされた場合は保存されないこと" do
      [
        bmp_file_name,
        txt_file_name,
      ].each do |image_name|
        micropost = @user.microposts.build(content: "Image upload test.")

        # バリデーションエラーが発生すること
        image = Rack::Test::UploadedFile.new("#{test_image_path}/#{image_name}")
        micropost.picture = image
        micropost.save
        expect(micropost).not_to be_valid
      end
    end
  end
end
