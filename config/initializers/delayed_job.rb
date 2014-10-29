Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 30
Delayed::Worker.max_run_time = 4.hours
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))