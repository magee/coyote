namespace :coyote do
  desc "Checks for new MCA images"
  task :update_mca do

    require 'multi_json'
    require 'open-uri'

    limit = 1000
    offset = 0
    if Image.count > 10 #kludge
      updated_at = (Time.zone.now - 1.minute).iso8601
    else
      updated_at = (Time.zone.now - 100.years).iso8601
    end

    length = 1 
    root = "https://cms.mcachicago.org"
    while length != 0 do
      url = root + "/api/v1/attachment_images?updated_at=#{updated_at}&offset=#{offset}&limit=#{limit}"
      Rails.logger.info "grabbing images for #{url}"

      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      rescue OpenURI::HTTPError => error
        response = error.io
        Rails.logger.error response.string
        length = 0
      end

      begin 
        images = JSON.parse(content)
      rescue Exception => e
        Rails.logger.error "JSON parsing exception"
        length = 0
      end

      length = images.length 

      images.each do |i|
        begin 
          image = Image.find_or_create_by(canonical_id:  i["id"])
          if image.new_record?
            image.website = Website.first
            group = Group.find_or_create_by(title: i["group"])
            group.save if group.new_record?
            image.group = group
            image.path = i["thumb_url"]
            image.created_at = i["created_at"]
            image.updated_at = i["updated_at"]
            image.save
            #create initial description field
            Rails.logger.info "created image #{image.id} from canonical id #{image.canonical_id}"
          else
            #update
            image.path = i["thumb_url"]
            image.updated_at = i["updated_at"]
            image.save
            Rails.logger.info "updated image #{image.id} from canonical id #{image.canonical_id}"
          end
          #create description if none are handy
          if image.descriptions.length == 0  and !i["title"].blank?
            d = Description.new(text: i["title"], locale: "en", metum_id: 1, image_id: image.id, status_id: 1, user_id: 1)
            d.save!
          end

        rescue Exception => e
          Rails.logger.error "image creation error"
          Rails.logger.error i
          Rails.logger.error e
        end
      end

      offset += limit
    end

    @their_count = offset
    @our_count = @website.images.count

  end
end