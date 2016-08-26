module Monitoring
  class OverviewController < Monitoring::ApplicationController
    authorization_required

    def index
      all_alarms = services.monitoring.alarms()
      
      # first count alarms states, severity and alarms ins status ALARM
      # severity_cnt_hash = Hash.new(0)
      state_cnt_hash    = Hash.new(0)
      alarm_cnt_hash    = Hash.new(0)
      unknown_cnt_hash  = Hash.new(0)
      ok_cnt_hash       = Hash.new(0)
      
      # @severity_cnt = 0;
      # all_alarms.map{|alarm| alarm.severity }.map{|severity| 
      #   severity_cnt_hash[severity] += 1 
      #   @severity_cnt += 1
      # }
      
      @alarm_cnt = 0;
      all_alarms.map{|alarm| alarm.state }.map{|state| 
        state_cnt_hash[state] += 1
        @alarm_cnt += 1
      }
      
      @state_alarm_cnt = state_cnt_hash['ALARM']
      @state_ok_cnt = state_cnt_hash['OK']
      @state_unknown_cnt = state_cnt_hash['UNDETERMINED']
      all_alarms.map{|alarm|
        if alarm.state == 'ALARM'
          alarm_cnt_hash[alarm.severity] += 1
        elsif alarm.state == 'OK'
          ok_cnt_hash[alarm.severity] += 1
        elsif alarm.state == 'UNDETERMINED'
          unknown_cnt_hash[alarm.severity] += 1
        end
      }

      # then build pie data
      @severity_pie_data    = Array.new
      @state_pie_data       = Array.new
      @state_alarm_pie_data = Array.new
      
      # severity data
      # @severity_pie_data = severity_cnt_hash.keys.sort.map{|severity| 
      #   { label: severity.capitalize, count: severity_cnt_hash[severity] }
      # }
      
      # all states data
      @state_pie_data = state_cnt_hash.keys.sort.map{|state| 
        # rename undetermined because it is to long for the chart label
        state_value = state_cnt_hash[state]
        state = "UNKNOWN" if state == 'UNDETERMINED'
        { label: state.capitalize, count: state_value } 
      }
      
      # only alarm state data
      @state_alarm_pie_data = alarm_cnt_hash.keys.sort.map{|state| 
        { label: state.capitalize, count: alarm_cnt_hash[state] }
      }

      # only ok state data
      @state_ok_pie_data = ok_cnt_hash.keys.sort.map{|state| 
        { label: state.capitalize, count: ok_cnt_hash[state] }
      }

      # only unkown state data
      @state_unknown_pie_data = unknown_cnt_hash.keys.sort.map{|state| 
        { label: state.capitalize, count: unknown_cnt_hash[state] }
      }

      # demo data to test styles
      # @state_pie_data << { label: "Unknown", count: 5 }
      # @severity_pie_data << { label: "Low", count: 5 }
      # @severity_pie_data << { label: "Medium", count: 8 }
    end

  end
end
