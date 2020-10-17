# frozen_string_literal: true

class Countries
  def self.all
    {
      JO: { country_code: "+962", format: 'X XXXX XXXX' },
      KW: { country_code: "+965", format: 'XXXX XXXX' },
      SA: { country_code: "+966", format: '5X XXX XXXX' }
    }
  end

  def self.flag_for(id)
    id.to_s.split('').map { |c| c.unpack('U').first + 0x1F1A5 }.pack('U*')
  end

  def self.from_id(id)
    id = id.to_s.to_sym unless Symbol === id
    all[id.upcase]
  end

  def self.valid_number?(id, number)
    return false if number.blank?

    country = from_id(id)
    raise "invalid country id" unless country

    format = country[:format].gsub(/\s/, '')
    number = number.gsub(/[^\d]/, '')
    return false if format.size != number.size

    format.split('').each_with_index.all? do |f, i|
      (f != 'X' && number[i] == f) || f == 'X'
    end
  end
end
