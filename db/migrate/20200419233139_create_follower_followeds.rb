class CreateFollowerFolloweds < ActiveRecord::Migration[5.2]
  def change
    create_table :follower_followeds do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    # ===== 検索速度を向上させるためのインデックス
    add_index(:follower_followeds, :follower_id)
    add_index(:follower_followeds, :followed_id)

    # ===== ユニークキーの設定
    # フォロー、フォロワーのユーザIDの複合ユニークキー
    add_index(
      :follower_followeds,
      [:follower_id, :followed_id],
      { unique: true },
    )
  end
end
