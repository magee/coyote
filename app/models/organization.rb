# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_title  (title) UNIQUE
#

# Represents a group of users, usually associated with a particular institution
class Organization < ApplicationRecord
  after_create :create_default_resource_group

  validates :title, presence: true, uniqueness: true

  has_many :memberships, inverse_of: :organization
  has_many :users, through: :memberships
  has_many :active_users, -> { where(memberships: { active: true }) }, source: :user, through: :memberships
  has_many :resources, dependent: :restrict_with_exception, inverse_of: :organization
  has_many :resource_groups, inverse_of: :organization
  has_many :meta, inverse_of: :organization
  has_many :assignments, through: :resources
  has_many :representations, through: :resources

  has_many :unassigned_unrepresented_resources, -> { unassigned_unrepresented }, class_name: :Resource

  def create_default_resource_group
    resource_groups.find_or_create_by(default: true, title: ResourceGroup::DEFAULT_TITLE)
  end

  def ready_to_review_representations
    representations.ready_to_review
  end
end
