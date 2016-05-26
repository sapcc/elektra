module Monitoring
  class OverviewController < Monitoring::ApplicationController
    authorization_required

    def index
      all_alarms = services.monitoring.alarms()
      @severity_cnt = Hash.new(0)
      @state_cnt = Hash.new(0)
      all_alarms.map{|alarm| alarm.severity }.map{|severity| @severity_cnt[severity] += 1}
      all_alarms.map{|alarm| alarm.state }.map{|state| @state_cnt[state] += 1}
    end

  end
end
