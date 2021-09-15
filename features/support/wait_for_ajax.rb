# helper for ajax calls
def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    while !finished_all_ajax_requests?  do
      sleep 1
    end

    # loop until finished_all_ajax_requests?
  end
end

def finished_all_ajax_requests?
  # jquery active ajax calls
  page.evaluate_script('jQuery.active').zero? &&
    # axios active ajax calls (see app/javascript/ajax_helper for more infos)
    (!page.evaluate_script('window.activeAjaxCallsCount') ||
    page.evaluate_script('window.activeAjaxCallsCount').zero?)
end

def all_ajax_calls_successful?
  !page.evaluate_script('window.failedAjaxCallsCount') || page.evaluate_script('window.failedAjaxCallsCount').zero?
end
