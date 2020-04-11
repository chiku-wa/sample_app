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

  # === カスタムバリデーション
  validate(:picture_size)

  # ======================================
  private

  # ===== カスタムバリデーション
  # ファイルサイズが許容しているサイズを上回っている場合はエラーとするバリデーション
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, :file_size_larger_than)
    end
  end
end
