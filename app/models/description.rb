# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string(255)      default("en")
#  text       :text(65535)
#  status_id  :integer
#  image_id   :integer
#  metum_id   :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#

class Description < ActiveRecord::Base

  belongs_to :status
  belongs_to :image
  belongs_to :metum
end
