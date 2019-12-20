module MailerMacros
  # HTML、テキストの本文が想定どおりであることを確認する
  def expected_body(mail, expected_string)
    puts "★"
    puts expected_string
    puts mail.text_part.body.to_s
    puts mail.html_part.body.to_s

    expect(mail.html_part.body.to_s).to match(expected_string)
    expect(mail.text_part.body.to_s).to match(expected_string)
  end
end