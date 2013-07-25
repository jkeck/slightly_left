class ImagesController < ApplicationController
  def index
    @images = InstagramImage.find("slightlyleft")
  end
end