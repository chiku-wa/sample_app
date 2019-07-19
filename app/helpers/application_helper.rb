module ApplicationHelper

  # 各ページのtitileを生成する
  def full_title(page_title = "")
    base_tiltle = "Ruby on Rails Tutorial Sample App"

    # ページ名が存在しない場合は「|」を表示しない
    if page_title.empty?
      base_tiltle
    else
      "#{page_title} | #{base_tiltle}"
    end
  end
end
