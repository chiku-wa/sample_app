module CommonMacros
  # =========================
  # 期待値確認用メソッド

  # =====
  # 統合テスト(features)用メソッド

  # ----- エラーメッセージに関する機能
  # 失敗メッセージを期待するメソッド
  def expect_failed_message(messages)
    # 失敗メッセージが表示されること
    expect(page).to have_selector(
      ".alert.alert-danger",
      text: "The form contains #{messages.size} error",
    )
    messages.each do |message|
      expect(page).to have_text(
        message,
      )
    end
  end

  # ----- ページネーションに関する機能
  # ページネーションバーが想定した数存在することを確認するメソッド
  def expect_pagination_bar(number_of)
    expect(page).to(have_link("Next →", count: number_of))
    expect(page).to(have_link("← Previous", count: number_of))
  end
end
