AuditDataFormatter = {}

AuditDataFormatter.buildTimeFilter = (filterStartTime, filterEndTime) ->
  timeFilter = ''

  if filterStartTime != null && (moment.isMoment(filterStartTime) || !ReactHelpers.isEmptyString(filterStartTime))
    timeFilter += "gte:#{filterStartTime}"

  console.log(timeFilter)

  if filterEndTime != null && (moment.isMoment(filterEndTime) || !ReactHelpers.isEmptyString(filterEndTime))
    timeFilter += "#{if timeFilter.length > 0 then ',' else ''}lte:#{filterEndTime}"

  timeFilter



@AuditDataFormatter = AuditDataFormatter
