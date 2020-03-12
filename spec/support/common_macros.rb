module CommonMacros
  # ---
  # 期待値確認用メソッド
  #

  # ===== ページネーションに関する機能
  # ページネーションバーが想定した数存在することを確認するメソッド
  def expect_pagination_bar(number_of)
    expect(page).to(have_link("Next →", count: number_of))
    expect(page).to(have_link("← Previous", count: number_of))
  end
end
