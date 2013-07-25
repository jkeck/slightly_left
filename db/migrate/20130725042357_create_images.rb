class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :thumbnail_url
      t.string :full_url
      t.string :caption
      t.string :source
      t.timestamps
    end
  end
end
