class HardJob
  include Sidekiq::Job

  def perform(*args)
    puts "World"
  end
end
