$KCODE = 'u'

class String
  def delithuanize!
    { 'Ą' => 'A', 'ą' => 'a',
      'Č' => 'C', 'č' => 'c',
      'Ę' => 'E', 'ę' => 'e',
      'Ė' => 'E', 'ė' => 'e',
      'Į' => 'I', 'į' => 'i',
      'Š' => 'S', 'š' => 's',
      'Ų' => 'U', 'ų' => 'u',
      'Ū' => 'U', 'ū' => 'u',
      'Ž' => 'Z', 'ž' => 'z'
    }.each do |from, to|
      self.gsub!(from, to)
    end
  end
end

#require 'date'
#class Date
#  MONTHNAMES = [nil, "Sausis", "Vasaris", "Kovas", "Balandis",
#    "Gegužė", "Birželis", "Liepa", "Rugpjūtis", "Rugsėjis", "Spalis",
#    "Lapkritis", "Gruodis"]
#end

class Time
  def lt
    to_s(:db)
  end
end

ActionMailer::Base.delivery_method = :sendmail
