namespace :assets do
  desc 'Uploads compiled assets (public/assets) to Amazon S3'
  task :upload, [:force, :noop] => ['assets:clean', 'assets:precompile'] do |_, args|
    args.with_defaults(force: false, noop: false)

    Dir.chdir("#{Rails.root}/public") do
      assets = FileList['assets', 'assets/**/*'].inject({}) do |hsh, path|
        if File.directory?(path)
          hsh.update("#{path}/" => :directory)
        else
          hsh.update(path => OpenSSL::Digest::MD5.hexdigest(File.read(path)))
        end
      end
      raise "[#{Rails.env}] public/assets is empty: aborting" if assets.size <= 1

      bucket_name = APP_CONFIG['assets_bucket']
      raise "[#{Rails.env}] can't find bucket name for assets: aborting" if bucket_name.blank?

      if Rails.env.staging?
        client = Aws::S3::Client.new(region: 'us-west-1')
        s3 = Aws::S3::Resource.new(endpoint: 'https://s3.amazonaws.com', client: client)
      else
        s3 = Aws::S3::Resource.new(endpoint: 'https://s3.amazonaws.com')
      end

      bucket = s3.bucket(bucket_name)

      assets.each do |file, etag|
        if etag == :directory
          puts "Directory #{file}"
          bucket.put_object(key: file) unless args[:noop]
        else
          if !args[:force] && bucket.object(file).exists? && bucket.object(file).etag == "\"#{etag}\""
            puts "Skipping #{file} (identical)"
          else
            puts "Uploading #{file}"

            if file.end_with?('.css')
              content_type = 'text/css'
            elsif file.end_with?('.js')
              content_type = 'text/javascript'
            end

            opts = {key: file, body: File.open(file), acl: 'public-read'}

            if content_type
              opts[:content_type] = content_type
            end

            bucket.put_object(opts) unless args[:noop]
          end
        end
      end
    end
  end
end
