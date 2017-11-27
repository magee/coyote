# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_title  (organization_id,title) UNIQUE
#

FactoryGirl.define do
  factory :resource_group do
    title { Faker::Lorem.unique.word }
    organization

    %i[collection website exhibitions events].each do |trait_name|
      trait trait_name do
        title trait_name
      end
    end
  end
end