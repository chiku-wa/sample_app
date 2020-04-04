class Micropost < ApplicationRecord
  # === 従属関係
  belongs_to :user

  # === ファイルのアップローダと紐付けるプロパティ
  mount_uploader :picture, PictureUploader

  # === バリデーション
  validates(
    :content,
    {
      presence: true,
      length: { maximum: 140 },
    },
  )
  # DBに保存されていないユーザの場合はマイクロポストが登録できないようにするためのバリデーション
  validates(
    :user_id,
    {
      presence: true,
    }
  )
end
