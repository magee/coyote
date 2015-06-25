# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  website_id :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_images_on_website_id  (website_id)
#

class Image < ActiveRecord::Base

  belongs_to :website
end
