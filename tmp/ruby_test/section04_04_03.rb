# encoding: utf-8

# ======
# 4.4.3
# ======
# 本来、Stringクラスにはpalindrome?メソッドは存在しないため呼び出し時にエラーになる
# str = "racecar"
# str.palindrome? #=> undefined method `palindrome?' for "racecar":String (NoMethodError)

# Stringクラスを再定義し、palindrome?メソッドを定義することで、Stringインスタンスで
# palindrome?メソッドを呼び出すことが可能になる
class String
  def palindrome?
    self == reverse
  end
end

str = "level"
p str.palindrome? #=> true

# ======
# 演習
# ======
# 1.
p "racecar".palindrome? #=> true
p "onomatopoeia".palindrome? #=> false

# 2.〜3.
class String
  def shuffle
    # splitを引数無しで呼び出すと空白が除去されるため、必ず空文字を引数として渡すこと
    split("").shuffle.join
  end
end

p "I am Tom.".shuffle
