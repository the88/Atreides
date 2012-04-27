if defined?(Delayed::Worker)
  Delayed::Worker.destroy_failed_jobs = true
  Delayed::Worker.max_attempts = 3
  Delayed::Worker.max_run_time = 10.minutes
end
