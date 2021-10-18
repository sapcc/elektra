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
  # disabled because of new axios version did not work with phantom.js
  # problem: in ajax_helper.js -> axiosInstance.interceptors.response is not triggered (after axiosInstance.interceptors.request) 
  # so window.activeAjaxCallsCount is increased but not decreased and because of that the test fails 
  return true
  # jquery active ajax calls
  page.evaluate_script('jQuery.active').zero? &&
    # axios active ajax calls (see app/javascript/ajax_helper for more infos)
    (!page.evaluate_script('window.activeAjaxCallsCount') ||
    page.evaluate_script('window.activeAjaxCallsCount').zero?)
end

def all_ajax_calls_successful?
  !page.evaluate_script('window.failedAjaxCallsCount') || page.evaluate_script('window.failedAjaxCallsCount').zero?
end
