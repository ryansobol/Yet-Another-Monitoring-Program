class WebWorker
  include Sidekiq::Worker

  def perform(web_monitor_id)
    web_monitor = WebMonitor.find(web_monitor_id)
    uri = URI(web_monitor.url)

    begin
      res = Net::HTTP.get_response(uri)
    rescue => e
      exception = e.message
    end

    if exception
      p = web_monitor.WebResults.build(
        successful: false,
        exception: exception
        )
    # Create alert
    elsif res.code != '200'
      p = web_monitor.WebResults.build(
        successful: false,
        status_code: res.code,
        )
        # Create alert
    else
      p = web_monitor.WebResults.build(
        successful: true,
        )
    end

    p.save
  end
end

