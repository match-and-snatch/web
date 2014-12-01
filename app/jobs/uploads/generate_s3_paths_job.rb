module Uploads
  class GenerateS3PathsJob
    def perform
      Document.where(s3_paths: nil).find_each do |document|
        bucket = Transloadit::Rails::Engine.configuration['templates']['post_document']['steps']['store']['bucket']

        index = document.transloadit_data['results'][':original'].index(document.transloadit_data['results'][':original'].select { |e| e['ssl_url'] == document.url }.first)

        next if index.blank?

        original = document.transloadit_data['results'][':original'][index]
        s3_paths = { bucket => [{ key: get_file_path(original['ssl_url']) }]}
        if document.transloadit_data['results']['preview']
          preview  = document.transloadit_data['results']['preview'][index]
          s3_paths[bucket] << { key: get_file_path(preview['ssl_url']) }
        end

        document.s3_paths = s3_paths
        document.save!
      end

      Audio.where(s3_paths: nil).find_each do |audio|
        template = audio.uploadable_type == 'User' ? 'welcome_media' : 'post_audio'
        bucket = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['bucket']

        index = audio.transloadit_data['results'][':original'].index(audio.transloadit_data['results'][':original'].select { |e| e['ssl_url'] == audio.url }.first)

        next if index.blank?

        original = audio.transloadit_data['results'][':original'][index]
        s3_paths = { bucket => [{ key: get_file_path(original['ssl_url']) }] }

        audio.s3_paths = s3_paths
        audio.save!
      end

      Video.where(s3_paths: nil).find_each do |video|
        template = video.uploadable_type == 'User' ? 'welcome_media' : 'post_video'

        preview_bucket = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['s3_thumb']['bucket']
        videos_bucket  = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['bucket']

        thumb    = video.transloadit_data['results']['thumbs'][0]
        encode   = video.transloadit_data['results']['encode'][0]
        original = video.transloadit_data['results'][':original'][0]

        s3_paths = { preview_bucket => [{ key: get_file_path(thumb['ssl_url']) }],
                     videos_bucket  => [encode.try(:[], 'ssl_url'), original.try(:[], 'ssl_url')].compact.map { |e| { key: get_file_path(e) } } }

        video.s3_paths = s3_paths
        video.save!
      end

      Photo.where(s3_paths: nil).find_each do |photo|
        if photo.uploadable_type == 'User'
          template = nil
          template = 'cover_picture' if photo.transloadit_data['results']['resized']
          template = 'profile_picture' if photo.transloadit_data['results']['thumb_180x180']

          s3_paths = {}
          if template.blank?
            photo.transloadit_data['results'].each do |step, files|
              bucket = URI(files[0]['ssl_url']).host.split('.').first
              s3_paths[bucket] ||= []
              s3_paths[bucket] << { key: get_file_path(files[0]['ssl_url']) }
            end
          else
            bucket = Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['bucket']

            s3_paths = { bucket => [] }
            Transloadit::Rails::Engine.configuration['templates'][template]['steps']['store']['use'].each do |key|
              s3_paths[bucket] << { key: get_file_path(photo.transloadit_data['results'][key][0]['ssl_url']) }
            end
          end

          photo.s3_paths = s3_paths
          photo.save!
        else
          bucket = Transloadit::Rails::Engine.configuration['templates']['post_photo']['steps']['store']['bucket']

          index = photo.transloadit_data['results'][':original'].index(photo.transloadit_data['results'][':original'].select { |e| e['ssl_url'] == photo.url }.first)

          next if index.blank?

          original = photo.transloadit_data['results'][':original'][index]
          preview  = photo.transloadit_data['results']['preview'][index]
          s3_paths = { bucket => [original['ssl_url'], preview['ssl_url']].map { |e| { key: get_file_path(e) } } }

          photo.s3_paths = s3_paths
          photo.save!
        end
      end
    end

    private

    def get_file_path(url = '')
      URI(url).path.sub('/', '')
    end
  end
end
