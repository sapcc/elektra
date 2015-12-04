module ResourceManagement
  module ResourceBarHelper

    # GUI component for a resource usage bar.
    #
    # Accepts the following options:
    #     fill:      { value: NUMBER, label: STRING }   - Size value and label for the usage display (required).
    #     maximum:   { value: NUMBER, label: STRING }   - Maximum value (determines scale), and label for the right edge.
    #     threshold: { value: NUMBER, label: STRING }   - Value and label for threshold mark.
    #     display_unit: NUMBER                          - Values will be divided by this unit when being interpolated into their label.
    #     warning_level: NUMBER                         - A number between 0 and 1. Beyond this ratio, fill levels will be rendered in warning color.
    # The hash arguments (fill, maximum, threshold) can also be given as a single number. Then the label is just the display value.
    #
    # The relation of usage to threshold determines the color of the usage display.
    # The threshold is not shown if it is larger than the maximum.
    # If the threshold is not given, the maximum value is used for the threshold, but without displaying it as threshold.
    # In all the label fields, a placeholder of $VALUE will be replaced with the value.
    def resource_bar(options = {})
      fill, maximum, threshold, upper_bound, warning_level = resbar_prepare_options(options)
      bars = resbar_compile_bars(fill, maximum, threshold, warning_level)

      return render('resource_bar_helper',
        bars:        bars,
        maximum:     maximum,
        threshold:   threshold,
        upper_bound: upper_bound,
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
      display_unit  = options.fetch(:display_unit,  1)
      warning_level = options.fetch(:warning_level, 0.8)

      # when only a number is given for some parameter, use the default label "$VALUE
      fill        = { value: fill,      label: "$VALUE" } unless fill.is_a?(Hash)
      maximum     = { value: maximum,   label: "$VALUE" } unless maximum.is_a?(Hash)
      threshold   = { value: threshold, label: "$VALUE" } unless threshold.is_a?(Hash)

      # check input validity
      raise ArgumentError, "fill value may not be negative"                if fill[:value] < 0
      raise ArgumentError, "maximum or threshold may not both be negative" if maximum[:value] < 0 && threshold[:value] < 0

      # choose upper_bound, the value that corresponds to the full width of the bar
      upper_bound = maximum[:value]
      if maximum[:value] < 0
        upper_bound = [ fill[:value], threshold[:value] ].max
      end

      # prepare labels
      [ fill, maximum, threshold ].each do |param|
        display_value = (param[:value].to_f / display_unit).to_i
        param[:label] = (param[:label] || '$VALUE').gsub("$VALUE", display_value.to_s)
      end

      # calculate percentages relative to maximum (for CSS)
      [ fill, threshold ].each do |param|
        if upper_bound == 0
          param[:percent] = param[:value] <= 0 ? 0 : (param[:value].to_i << 10) # avoid division by zero, just scale very large
        else
          param[:percent] = param[:value] <= 0 ? 0 : (param[:value].to_f / upper_bound * 100).to_i
        end
      end

      return [ fill, maximum, threshold, upper_bound, warning_level ]
    end

    # This prepares a list of all the progress bars that we're placing in the
    # resource bar (i.e. all the <div class="progress-bar">).
    def resbar_compile_bars(fill, maximum, threshold, warning_level)
      bars = []

      # place label next to bar instead of on bar?
      outside_label = fill[:percent] < 5 ? fill[:label] : ''

      if fill[:value] > 0
        # render normal bar
        fill_level = fill[:value].to_f / [ threshold[:value], maximum[:value] ].select { |x| x > 0 }.min.to_f
        bar_type   = fill_level >= 1.0           ? 'danger'
                   : fill_level >= warning_level ? 'warning' : 'default'
        # the normal bar may not exceed the threshold mark
        if threshold[:value] > 0
          percent = [ fill[:percent], threshold[:percent] ].min
        else
          percent = fill[:percent]
        end
        bars << { type: bar_type, percent: percent, label: outside_label == '' ? fill[:label] : '' }

        # mark the filled part beyond the threshold as "overcommit"
        if fill[:value] > threshold[:value]
          bars << { type: 'danger-overcommit', percent: fill[:percent] - threshold[:percent] }
        end
      end

      if maximum[:value] > 0
        # for finite maximum, mark empty area beyond the threshold as "overcommit"
        if threshold[:value] < maximum[:value]
          if fill[:value] >= threshold[:value]
            bars << { type: 'empty-overcommit', percent:                 100 - fill[:percent], label: outside_label }
          else
            bars << { type: 'empty',            percent: threshold[:percent] - fill[:percent], label: outside_label }
            bars << { type: 'empty-overcommit', percent: 100 - threshold[:percent] }
          end
        elsif outside_label != ""
          bars << { type: 'empty', label: outside_label }
        end
      else
        # for infinite maximum, mark all empty area as "overcommit"
        bars << { type: 'empty-overcommit', percent: 100 - fill[:percent], label: outside_label }
      end

      # remove all empty labels
      bars.each { |bar| bar.delete(:label) if bar[:label] == '' }
      # remove all bars with fixed width that was calculated to be non-positive
      return bars.reject { |bar| bar.has_key?(:percent) && bar[:percent] <= 0 }
    end

  end
end
