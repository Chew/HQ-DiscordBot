class Integer
  def to_sc(delimiter = ',', numbers_per_section = 3)
    to_s.gsub(/(\d)(?=\d{#{numbers_per_section}}+(\.\d*)?$)/, '\1' + delimiter)
  end
end
