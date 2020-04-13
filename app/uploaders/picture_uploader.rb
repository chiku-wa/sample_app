class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process resize_to_limit: [400, 400]

  # 本番環境の場合はクラウド上のサービスに画像を保存する
  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # 許容する画像サイズを定義する
  def size_range
    1.byte..5.megabyte
  end

  # アップロードできるファイルの拡張子のホワイトリストを定義する
  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
