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

# Stringを継承して作り直してみる
class WordInherit < String
  # Rubyでは、initializeメソッドを省略した場合、継承元のStringクラスのinitializeメソッドが
  # 自動的に呼び出される。

  # クラス直下のselfは、クラスそのものを指す
  p "クラス直下のself:#{self}" #=> WordInherit

  # インスタンスメソッド直下でselfを呼び出すと、newの引数に渡した文字列が呼び出される
  def palindrome?
    # ・インスタンスメソッド直下のselfは、インスタンスを意味する
    # ・つまり、selfはnewしたときに生成されたオブジェクトを指す
    # ・initializeメソッドを省略しているので、newした時にはStringクラスのinitialize
    #   メソッドが呼び出されている。
    # ・よって、selfはStringクラスのインスタンスとして機能する
    p "インスタンスメソッド直下のself:#{self}" #=> newの引数に渡した文字列

    # selfはStringのインスタンスであるため、selfは「new String("foobar")」ひいては
    # 「"foobar"」と同じ意味となる。
    # よって以下の記述が可能。
    self == self.reverse

    # Rubyではselfは省略可能なため、以下の記述も可能。
    # self == reverse
  end
end

wi = WordInherit.new("foobar")
p wi.palindrome? #=> false

wi = WordInherit.new("racecar")
p wi.palindrome? #=> true
