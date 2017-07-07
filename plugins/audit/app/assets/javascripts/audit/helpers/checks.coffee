AuditHelpers = {}

AuditHelpers.isValidDate = (date) ->
  # do not allow dates that are in the future
  !moment(date).isAfter()



@AuditHelpers = AuditHelpers
