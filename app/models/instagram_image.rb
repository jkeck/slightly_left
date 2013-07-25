require "net/http"
class InstagramImage
  def self.find tag
    if self.refresh_from_instagram?
      data = Net::HTTP.get self.instagram_url(tag)
      json = JSON.parse data
      return [] unless json["data"]
      selected_images = json["data"].select do |data|
        self.known_user_ids.include? data["user"]["id"]
      end
      unless selected_images.blank?
        self.instagram_images_from_database.map{|image| image.destroy }
        selected_images.map do |data|
          img = Image.new
          img.thumbnail_url = data["images"]["thumbnail"]["url"]
          img.full_url = data["images"]["standard_resolution"]["url"]
          img.caption = data["caption"]["text"]
          img.source = "Instagram"
          img.save
          img
        end
      else
        self.instagram_images_from_database
      end
    else
      self.instagram_images_from_database
    end
  end

  private
  def self.instagram_images_from_database
    Image.where(source: "Instagram")
  end
  def self.refresh_from_instagram?
    return true if self.instagram_images_from_database.blank?
    (self.instagram_images_from_database.first.created_at + 10.minutes) < Time.now.utc
  end
  def self.instagram_url tag
    URI.parse "https://api.instagram.com/v1/tags/#{tag}/media/recent?access_token=#{self.access_token}"
  end
  def self.access_token
    SlightlyLeft::Application.config.instagram_access_token
  end
  def self.known_user_ids
    SlightlyLeft::Application.config.allowed_instagram_ids
  end

end