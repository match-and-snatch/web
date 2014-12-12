config = YAML.load_file(Rails.root.join('config', 'transloadit.yml'))['s3']

Aws.config[:credentials] = Aws::Credentials.new(config['key'], config['secret'])
Aws.config[:region] = 'us-west-1'