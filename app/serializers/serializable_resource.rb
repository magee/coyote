# JSONAPI serializer for Resources
class SerializableResource < JSONAPI::Serializable::Resource
  type 'resource'

  id { @object.identifier }
  attributes :title, :resource_type, :canonical_id, :source_uri, :created_at, :updated_at

  attribute :context do
    @object.context_title
  end

  belongs_to :organization

  has_many :representations do
    data do
      @object.approved_representations
    end

    link :related do
      @url_helpers.api_resource_representations_url(@object.id)
    end
  end

  link :self do
    @url_helpers.api_resource_url(@object.id)
  end
end
