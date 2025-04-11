namespace :test do
  desc "Test solid_queue setup by enqueuing a test job"
  task queue: :environment do
    puts "Enqueuing test job..."
    job = TestJob.perform_later("Hello from solid_queue!")
    puts "Test job enqueued successfully!"
    
    puts "\nJob details:"
    puts "  Job ID: #{job.job_id}"
    puts "  Queue: #{job.queue_name}"
    puts "  Arguments: #{job.arguments}"
  end
end 