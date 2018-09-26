// time was. To be used for creation and modification timestamps.

const seconds = (date) => date.getTime() / 1000
const minutes = (date) => seconds(date) / 60
const hours = (date) => minutes(date) / 60
const days = (date) => hours(date) / 24
const months = (date) => days(date) / (365/12)
const years = (date) => months(date) / 12

export const formatModificationTime = (mtime) => {
  // check for exact class (can't rely on duck-typing here since different
  // datetime classes behave subtly different; e.g. subtraction of
  // DateTime gives a diff in days, but subtraction of
  // ActiveSupport::TimeWithZone gives a diff in seconds)
  if(typeof mtime == 'string') mtime = new Date(mtime)
  if(!mtime) return ''

  const now = new Date()
  // the minus operator returns the difference in days; convert to seconds
  let diffInSeconds = parseInt(seconds(now) - seconds(mtime))
  let text;

  if(diffInSeconds < 0) {
    // please check your NTP client :)
    text = 'soon'
  } else if(diffInSeconds < 60) {
    text = 'just now'
  } else if(diffInSeconds < 60 * 60) {
    let diffInMinutes = parseInt(diffInSeconds / 60)
    text = diffInMinutes == 1 ? '1 minute ago' : `${diffInMinutes} minutes ago`
  } else if(diffInSeconds < 60 * 60 * 24) {
    let diffInHours = parseInt(diffInSeconds / 60 / 60)
    text = diffInHours == 1 ? '1 hour ago' : `${diffInHours} hours ago`
  // } else {
  //   // count actual calendar days
  //   let diffInFullDays = parseInt(days(now)) - parseInt(days(mtime))
  //   text = diffInFullDays == 1 ? 'yesterday' : `${diffInFullDays} days ago`
  // }
} else if(diffInSeconds < 60 * 60 * 24 * 365/12) {
  // count actual calendar days
  let diffInFullDays = parseInt(days(now)) - parseInt(days(mtime))
  text = diffInFullDays == 1 ? 'yesterday' : `${diffInFullDays} days ago`
} else {
  let diffInMonths = parseInt(months(now)) - parseInt(months(mtime))
  text = diffInMonths == 1 ? 'one month ago' : `${diffInMonths} months ago`
}

  // show exact mtime in tooltip (like Github does)
  return text
}
