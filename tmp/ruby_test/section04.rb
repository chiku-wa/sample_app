# 継承を用いず
class Word
  # 回文ならtrue、そうでいないならfalseを返す
  def palindrome?(string)
    string == string.reverse
  end
end

w = Word.new
p w.palindrome?("foobar") #=> false
p w.palindrome?("level") #=> true
