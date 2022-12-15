export default function Deferred() {
  this.promise = new Promise(
    function (resolve, reject) {
      this.resolve = resolve
      this.reject = reject
    }.bind(this)
  )

  this.catch = this.promise.catch.bind(this.promise)
  this.then = this.promise.then.bind(this.promise)
}
