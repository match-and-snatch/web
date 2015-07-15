namespace :uploads do
  desc 'Generate and store s3 paths for existing uploads'
  task generate_s3_paths: :environment do
    Uploads::GenerateS3PathsJob.new.perform
  end

  desc 'Populates cover picture width and height'
  task set_dims: :environment do
    i = 0
    base_width = 940
    base_height = 208
    User.where("cover_picture_url IS NOT NULL").find_each do |user|
      upload = Photo.where(url: user.original_cover_picture_url).first

      if upload
        meta = upload.attr_on_step('resized', 'meta')

        if meta
          width = meta['width']
          height = meta['height']
        else
          width = upload.width
          height = upload.height
        end

        if width && height
          user.cover_picture_width = width
          user.cover_picture_height = height

          dim = base_width / width.to_f

          if user.cover_picture_position.zero?
            user.cover_picture_position_perc = 0
          else
            norm_pos_mul = -1 * user.cover_picture_position / height
            norm_pos = user.cover_picture_position + height * norm_pos_mul
            puts norm_pos.inspect
            move_space = height - base_height # 800 - 208 = 592

            perc = norm_pos.to_f / move_space # -74 / 592

            user.cover_picture_position_perc = perc * -100
          end

          user.save!

          i += 1

          puts "UserID: #{user.id}, i: #{i}, #{user.cover_picture_position_perc}"
        else
          puts "Skipping #{user.id}: #{user.slug}"
        end
      end
    end
  end
end
