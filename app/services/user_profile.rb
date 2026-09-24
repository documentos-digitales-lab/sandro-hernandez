class UserProfile
  attr_reader :full_name, :image_url

  def self.null
    @null ||= Null.new
  end

  def initialize(full_name:, image_url: nil)
    @full_name = full_name
    @image_url = image_url
  end

  def to_h
    { full_name: full_name, image_url: image_url }
  end

  def present?
    true
  end

  def null?
    false
  end

  class Null
    def full_name
      nil
    end

    def image_url
      nil
    end

    def to_h
      nil
    end

    def present?
      false
    end

    def null?
      true
    end
  end
end