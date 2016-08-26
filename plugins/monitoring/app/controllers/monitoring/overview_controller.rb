module Monitoring
  class OverviewController < Monitoring::ApplicationController
    authorization_required

    def index
      all_alarms = services.monitoring.alarms()
      
      # count alarms states and severity
      severity_cnt_hash = Hash.new(0)
      state_cnt_hash = Hash.new(0)
      @alarm_cnt = 0;
      @severity_cnt = 0;
      all_alarms.map{|alarm| alarm.severity }.map{|severity| 
        severity_cnt_hash[severity] += 1 
        @severity_cnt += 1
      }
      all_alarms.map{|alarm| alarm.state }.map{|state| 
        state_cnt_hash[state] += 1
        @alarm_cnt += 1
      }
      
      @severity_pie_data = Array.new
      @state_pie_data = Array.new
      @severity_pie_data = severity_cnt_hash.keys.sort.map{|severity| { label: severity.capitalize, count: severity_cnt_hash[severity] }}
      @state_pie_data = state_cnt_hash.keys.sort.map{|state| 
        # rename undetermined because it is to long for the chart label
        state_value = state_cnt_hash[state]
        state = "UNKNOWN" if state == 'UNDETERMINED'
        { label: state.capitalize, count: state_value } 
      }

      # demo data to test styles
      # @state_pie_data << { label: "Unknown", count: 5 }
      # @severity_pie_data << { label: "Low", count: 5 }
      # @severity_pie_data << { label: "Medium", count: 8 }
    end

  end
end
