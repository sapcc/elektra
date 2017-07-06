AuditDataFormatHelpers = {}

AuditDataFormatHelpers.buildTimeFilter = (filterStartTime, filterEndTime) ->
  timeFilter = ''

  if filterStartTime != null && (moment.isMoment(filterStartTime) || !ReactHelpers.isEmptyString(filterStartTime))
    timeFilter += "gte:#{filterStartTime}"

  if filterEndTime != null && (moment.isMoment(filterEndTime) || !ReactHelpers.isEmptyString(filterEndTime))
    timeFilter += "#{',' if timeFilter.length > 0}lte:#{filterEndTime}"

  timeFilter



@AuditDataFormatHelpers = AuditDataFormatHelpers
