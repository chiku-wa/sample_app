require "rails_helper"

RSpec.describe "MicropostsController-requests", type: :request do
  # 画像が保存されるディレクトリ
  let(:image_save_path) { File.join(Rails.root, "public/uploads/micropost/picture") }

  # ===== 予め用意したテスト用画像の情報を定義
  # ディレクトリ
  let(:test_image_path) { File.join(Rails.root, "spec/fixtures") }
  # 正常系テスト用の画像ファイル名を定義
  let(:jpg_file_name) { "sample.jpg" }
  let(:boundary_size_file_name) { "boundary_size.jpg" }
  # 異常系テスト用の画像ファイル名を定義
  let(:bmp_file_name) { "sample.bmp" }
  let(:over_size_file_name) { "over_size.jpg" }

  before "テストユーザ登録" do
    # --- マイクロソフトの取得順序テスト用のデータ
    @user = FactoryBot.build(:user)
    @user.save

    [
      # テストを正確にするため、レコードの作成日時が古い順に登録する
      FactoryBot.build(:micropost_3years_ago),
      FactoryBot.build(:micropost_2hours_ago),
      FactoryBot.build(:micropost_10min_ago),
      FactoryBot.build(:micropost_latest),
    ].each do |m|
      @user.microposts.build(content: m.content, created_at: m.created_at)
    end
    @user.save
  end

  context "マイクロポストの新規登録に関するテスト" do
    it "画像をアップロードせず、本文のみで正常に登録できること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      size_before_update = @user.microposts.size

      # 登録するとマイクロポストが1件登録されていること
      micropost_map = { content: Faker::Lorem.sentence }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(1)

      # TOP画面に遷移すること
      follow_redirect!
      assert_template "static_pages/home"

      # ユーザに紐づくマイクロポストが登録されていること
      @user.reload
      expect(@user.microposts.size).to eq (size_before_update + 1)
    end

    it "許可されている拡張子の画像のみ正常にアップロードできること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      size_before_update = @user.microposts.size

      # 画像つきでマイクロポストを投稿する
      image = Rack::Test::UploadedFile.new("#{test_image_path}/#{jpg_file_name}")
      micropost_map = {
        content: Faker::Lorem.sentence,
        picture: image,
      }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(1)

      # TOP画面に遷移すること
      follow_redirect!
      assert_template "static_pages/home"

      # ユーザに紐づくマイクロポストが登録されていること
      @user.reload
      expect(@user.microposts.size).to eq (size_before_update + 1)

      # 画像がアップロードされていること
      posted_micropost = @user.microposts.find_by(picture: jpg_file_name)

      expect(posted_micropost).not_to be_nil
      expect(
        File.exist?("#{image_save_path}/#{posted_micropost.id}/#{jpg_file_name}")
      ).to be_truthy
    end

    it "許可されていない拡張子のファイルの場合は投稿できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # 画像つきでマイクロポストを投稿する
      image = Rack::Test::UploadedFile.new("#{test_image_path}/#{bmp_file_name}")
      micropost_map = {
        content: Faker::Lorem.sentence,
        picture: image,
      }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(0)
    end

    it "5MB以下のファイルのみアップロードできること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ===== 5MBの画像をアップロードすると投稿に成功すること
      # 画像がアップロードされていること
      image = Rack::Test::UploadedFile.new(
        "#{test_image_path}/#{boundary_size_file_name}"
      )
      micropost_map = {
        content: Faker::Lorem.sentence,
        picture: image,
      }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(1)

      posted_micropost = @user.microposts.find_by(picture: boundary_size_file_name)

      expect(posted_micropost).not_to be_nil
      expect(
        File.exist?("#{image_save_path}/#{posted_micropost.id}/#{jpg_file_name}")
      ).to be_truthy

      # ===== 5MBを超える画像の場合は投稿できないこと
      image = Rack::Test::UploadedFile.new(
        "#{test_image_path}/#{over_size_file_name}"
      )
      micropost_map = {
        content: Faker::Lorem.sentence,
        picture: image,
      }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(0)
    end

    it "画像あり、本文なしの場合はアップロードできないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # 画像のみでマイクロポストを投稿する
      image = Rack::Test::UploadedFile.new("#{test_image_path}/#{jpg_file_name}")
      micropost_map = {
        picture: image,
      }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(0)
    end

    it "空文字の場合は値を登録できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      # マイクロポストが登録されないこと
      micropost_map = { content: "" }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(0)
    end

    it "文字数超過の場合は値を登録できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      # マイクロポストが登録されないこと
      micropost_map = { content: "a" * 141 }
      expect {
        post microposts_path, params: { micropost: micropost_map }
      }.to change(Micropost, :count).by(0)
    end

    it "Content以外の要素をリクエストで更新できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      micropost_map = { content: Faker::Lorem.sentence }

      # 日付を明示して更新をリクエストする
      not_expect_created_at = Time.new(1990, 1, 1)
      micropost_map[:created_at] = not_expect_created_at
      post microposts_path, params: { micropost: micropost_map }

      # 指定した作成日時でマイクロポストが登録されていないこと
      expect(Micropost.where(created_at: not_expect_created_at).size).to eq 0
    end
  end

  context "マイクロポストを削除する機能のテスト" do
    it "正常に削除できること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # 削除対象のマイクロポストを取得する
      expect_delete_micropost = Micropost.first

      # マイクロポストを削除すると1件減っていること
      expect {
        delete micropost_path(expect_delete_micropost.id)
      }.to change(Micropost, :count).by(-1)

      # 想定したマイクロポストが削除できていること
      expect(Micropost.find_by(id: expect_delete_micropost.id)).to be_nil
    end

    it "ユーザ自身が保有するマイクロポストしか削除できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ログインしているユーザとは別のユーザでマイクロポストを投稿する
      user_second = FactoryBot.build(:user_second)
      user_second.save
      user_second.microposts.build(content: Faker::Lorem.sentence)
      user_second.save

      # 別のユーザのマイクロポストは削除できず、TOP画面に遷移すること
      expect {
        delete micropost_path(user_second.microposts.first.id)
      }.to change(Micropost, :count).by(0)
      expect(response).to redirect_to(root_url)
    end
  end

  context "未ログインユーザのアクセスが許可されていないアクションのテスト" do
    it "未ログインの場合にマイクロポストを新規に登録しようとした場合はログインページに遷移すること" do
      micropost_map = { content: Faker::Lorem.sentence }
      post microposts_path, params: { micropost: micropost_map }
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end

    it "未ログインの場合にマイクロポストを削除しようとした場合はログインページに遷移すること" do
      delete micropost_path(@user.microposts.first.id)
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end
  end
end
