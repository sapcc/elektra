module ResourceManagement
  module ResourceBarHelper

    # GUI component for a resource usage bar.
    #
    # Accepts the following options:
    #     fill:      { value: NUMBER, label: STRING }                                - Size value and label for the usage display (required).
    #     maximum:   { value: NUMBER, label: STRING }                                - Maximum value (determines scale), and label for the right edge.
    #     threshold: { value: NUMBER, label: STRING }                                - Value and label for threshold mark.
    #     marker:    { value: NUMBER, label: STRING, related_to_threshold: BOOLEAN } - Value and label for a second mark.
    #                                                                                  related_to_threshold scale to the threshold value (default it's upper_bound)

    #     data_type:     Core::DataType                 - If given, render values with its format() method.
    #     warning_level: NUMBER                         - A number between 0 and 1. Beyond this ratio, fill levels will be rendered in warning color (default 0.8).
    #     danger_level: NUMBER                          - A number from 1 to N. Beyond this number, fill levels will be rendered in danger color (default 1.0).
    # The hash arguments (fill, maximum, threshold) can also be given as a single number. Then the label is just the display value.
    #
    # The relation of usage to threshold determines the color of the usage display.
    # The threshold is not shown if it is larger than the maximum.
    # If the threshold is not given, the maximum value is used for the threshold, but without displaying it as threshold.
    # In all the label fields, a placeholder of $VALUE will be replaced with the value.
    def resource_bar(options = {})

      # delete threshold if value is 0
      options.delete(:threshold) if options[:threshold] == 0
      options.delete(:threshold) if options[:threshold].is_a?(Hash) &&  options[:threshold][:value] == 0

      fill, maximum, threshold, upper_bound, warning_level, danger_level, marker = resbar_prepare_options(options)
      bars = resbar_compile_bars(fill, maximum, threshold, warning_level, danger_level, marker)

      return render('resource_bar_helper',
        bars:        bars,
        maximum:     maximum,
        threshold:   threshold,
        upper_bound: upper_bound,
        marker:      marker,
      )
    end

    private

    # Reads and validates the arguments given to resource_bar(), and performs
    # some pre-computations.
    def resbar_prepare_options(options)
      raise ArgumentError, "missing required argument 'fill'" unless options.has_key?(:fill)

      # default values
      fill          = options[:fill]
      maximum       = options.fetch(:maximum,       fill)
      threshold     = options.fetch(:threshold,     maximum)
      data_type     = options.fetch(:data_type,     nil) || Core::DataType.new(:number)
      warning_level = options.fetch(:warning_level, 0.8)
      danger_level  = options.fetch(:danger_level,  1.0)
      marker        = options.fetch(:marker,        maximum)

      # when only a number is given for some parameter, use the default label "$VALUE
      fill        = { value: fill,      label: "$VALUE" } unless fill.is_a?(Hash)
      maximum     = { value: maximum,   label: "$VALUE" } unless maximum.is_a?(Hash)
      threshold   = { value: threshold, label: "$VALUE" } unless threshold.is_a?(Hash)
      marker    =   { value: marker,    label: "$VALUE" } unless marker.is_a?(Hash)

      # choose upper_bound, the value that corresponds to the full width of the bar
      upper_bound = maximum[:value]
      if maximum[:value] < 0
        upper_bound = [ fill[:value], threshold[:value] ].max
      end

      # prepare labels
      #[ fill, maximum, threshold ].each do |param|
      [ fill, maximum, threshold, marker ].each do |param|
        display_value = data_type.format(param[:value])
        param[:label] = (param[:label] || '$VALUE').gsub("$VALUE", display_value)
      end

      # calculate percentages relative to maximum (for CSS)
      # percentages are calculated in relation to "maximum"
      # "maximum" can be the fill or the maximum level
      [ fill, threshold, marker].each do |param|
        if upper_bound == 0
          param[:percent] = param[:value] <= 0 ? 0 : (param[:value].to_i << 10) # avoid division by zero, just scale very large
        else
          param[:percent] = param[:value] <= 0 ? 0 : (param[:value].to_f / upper_bound * 100).to_i
        end
      end

      # special case the marker is not related to maximum but to threshold
      # |-----------|-----------------------|---------------------------------|
      # | fill |    |                       |                                 |
      # |-----------|-----------------------|---------------------------------|
      # |<---30%--->| marker                | threshold                       | max
      # |<-----------------100%------------>| related_to_threshold            | upper_bound
      # |<---------------------------------200%-------------------------------| related to threshold
      # |<---------------------------------100%-------------------------------| related to max (upper bound)

      # related_to_threshold means threshold is 100% for the scale of the marker
      # default it's upper_bound
      if marker[:related_to_threshold]
        if marker[:value] < threshold[:value]
          one_percent = threshold[:value].to_f / 100

          # calculate the factor percentage
          # for instance: threshold = 100 and upper_bound = 200 the factor 2
          factor = 1
          if threshold[:value] < upper_bound
            factor = upper_bound.to_f / threshold[:value].to_f
          end
          value = (marker[:value].to_f / one_percent).to_f / factor

          # debug
          # puts "threshold #{threshold[:value]}"
          # puts "marker #{marker[:value]}"
          # puts "upper_bound #{upper_bound}"
          # puts "one_percent #{one_percent}"
          # puts "factor #{factor}"
          # puts "value #{value}"

          marker[:percent] = value.round(1)
        end
      end
      return [ fill, maximum, threshold, upper_bound, warning_level, danger_level, marker ]
    end

    # This prepares a list of all the progress bars that we're placing in the
    # resource bar (i.e. all the <div class="progress-bar">).
    def resbar_compile_bars(fill, maximum, threshold, warning_level, danger_level, marker)
      bars = []

      if fill[:value] > 0
        # render normal bar
        fill_level = fill[:value].to_f / [ threshold[:value], maximum[:value] ].select { |x| x > 0 }.min.to_f

        bar_type   = fill_level >= danger_level  ? 'danger'
                   : fill_level >= warning_level ? 'warning' : 'default'
        # the normal bar may not exceed the threshold mark
        if threshold[:value] >= 0
          percent = [ fill[:percent], threshold[:percent] ].min
        else
          percent = fill[:percent]
        end
        bars << { type: bar_type, percent: percent } # label will be added at the end

        # mark the filled part beyond the threshold as "overcommit"
        if fill[:value] > threshold[:value]
          bars << { type: 'danger-overcommit', percent: fill[:percent] - threshold[:percent] }
        end
      end

      if maximum[:value] > 0
        # for finite maximum, mark empty area beyond the threshold as "overcommit"
        if threshold[:value] < maximum[:value]
          if fill[:value] >= threshold[:value]
            bars << { type: 'empty-overcommit', percent:                 100 - fill[:percent] }
          else
            bars << { type: 'empty',            percent: threshold[:percent] - fill[:percent] }
            bars << { type: 'empty-overcommit', percent: 100 - threshold[:percent] }
          end
        else
          bars << { type: 'empty', percent: 100 - fill[:percent] }
        end

      else
        # for infinite maximum, mark all empty area as "overcommit"
        bars << { type: 'empty-overcommit', percent: 100 - fill[:percent] }
      end

      # remove all bars with fixed width that was calculated to be non-positive
      bars = bars.reject { |bar| bar[:percent] <= 0 }

      # place the fill label on the first bar that is not small
      required_size_for_label = 1.5 * fill[:label].size
      bar_for_label = bars.find { |bar| bar[:percent] > required_size_for_label }
      bar_for_label[:label] = fill[:label]

      # remove unused trailing spacer
      bars.pop if bars.last[:type] == 'empty' and not bars.last.has_key?(:label)

      # if all the bars add up to 100%, make the last one ever so slightly
      # slimmer to avoid a line break (which might occur if there are rounding
      # errors in the browser's rendering engine)
      bars.last[:percent] -= 0.1 if bars.map { |bar| bar[:percent] }.sum > 99.99

      return bars
    end

  end
end
