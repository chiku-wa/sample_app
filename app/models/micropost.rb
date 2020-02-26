class Micropost < ApplicationRecord
  # === 従属関係
  belongs_to :user

  # === バリデーション
  validates(
    :content,
    {
      presence: true,
      length: { maximum: 140 },
    },
  )
end
