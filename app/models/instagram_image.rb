require "net/http"
class InstagramImage
  attr_accessor :tag
  def initialize(tag)
    @tag = tag
  end
  
  def self.find tag
    InstagramImage.new(tag).find
  end
  
  def find
    if refresh_from_instagram?
      unless json_from_instagram["data"] and images_from_allowed_users.blank?
        InstagramImage.destroy_all
        images = selected_images
        if json_from_instagram["pagination"] and json_from_instagram["pagination"]["next_url"]
          next_page = json_from_instagram(json_from_instagram["pagination"]["next_url"])
          images << selected_images(images_from_allowed_users(next_page))
        end
        images.flatten
      else
        instagram_images_from_database
      end
    else
      instagram_images_from_database
    end
  end

  private
  def selected_images images = images_from_allowed_users
    images.map do |data|
      img = Image.new
      img.thumbnail_url = data["images"]["thumbnail"]["url"]
      img.full_url = data["images"]["standard_resolution"]["url"]
      img.caption = data["caption"]["text"]
      img.source = InstagramImage.source
      img.save
      img
    end
  end
  def json_from_instagram url = instagram_url
    JSON.parse Net::HTTP.get URI.parse(url)
  end
  def images_from_allowed_users json = json_from_instagram
    return [] unless json["data"]
    json["data"].select do |data|
      known_user_ids.include? data["user"]["id"]
    end
  end
  def instagram_images_from_database
    @instagram_images_from_database ||= Image.where(source: InstagramImage.source)
  end
  def refresh_from_instagram?
    return true if instagram_images_from_database.blank?
    (instagram_images_from_database.first.created_at + 10.minutes) < Time.now.utc
  end
  def instagram_url
    "https://api.instagram.com/v1/tags/#{tag}/media/recent?access_token=#{access_token}"
  end
  def access_token
    SlightlyLeft::Application.config.instagram_access_token
  end
  def known_user_ids
    SlightlyLeft::Application.config.allowed_instagram_ids.split(",").map(&:strip)
  end
  def self.source
    "Instagram"
  end
  def self.destroy_all
    Image.where(source: InstagramImage.source).each do |image|
      image.destroy
    end
  end
end