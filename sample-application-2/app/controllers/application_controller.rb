class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def enqueue_jobs
    jobs_count = params[:jobs].to_i
    jobs_count.times{ EchoJob.perform_later }
    res = {
      "server_response": "added #{jobs_count} jobs"
    }
    render :plain => res.to_json, status:200, content_type: "application/json"
  end

end