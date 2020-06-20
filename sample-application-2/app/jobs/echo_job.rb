class EchoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    sleep 10
    puts "ECHO JOB: #{self.object_id} | #{Time.now}"
    `echo "ECHO JOB: #{self.object_id} | #{Time.now}" >> #{File.join(Rails.root, 'tmp', 'echo.output')}`
  end
end
