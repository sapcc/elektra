/*
 * jQuery BBQ: Back Button & Query Library - v1.3pre - 8/26/2010
 * http://benalman.com/projects/jquery-bbq-plugin/
 *
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
;(function ($, r) {
  var h,
    n = Array.prototype.slice,
    t = decodeURIComponent,
    a = $.param,
    j,
    c,
    m,
    y,
    b = ($.bbq = $.bbq || {}),
    s,
    x,
    k,
    e = $.event.special,
    d = "hashchange",
    B = "querystring",
    F = "fragment",
    z = "elemUrlAttr",
    l = "href",
    w = "src",
    p = /^.*\?|#.*$/g,
    u,
    H,
    g,
    i,
    C,
    E = {}
  function G(I) {
    return typeof I === "string"
  }
  function D(J) {
    var I = n.call(arguments, 1)
    return function () {
      return J.apply(this, I.concat(n.call(arguments)))
    }
  }
  function o(I) {
    return I.replace(H, "$2")
  }
  function q(I) {
    return I.replace(/(?:^[^?#]*\?([^#]*).*$)?.*/, "$1")
  }
  function f(K, P, I, L, J) {
    var R, O, N, Q, M
    if (L !== h) {
      N = I.match(K ? H : /^([^#?]*)\??([^#]*)(#?.*)/)
      M = N[3] || ""
      if (J === 2 && G(L)) {
        O = L.replace(K ? u : p, "")
      } else {
        Q = m(N[2])
        L = G(L) ? m[K ? F : B](L) : L
        O = J === 2 ? L : J === 1 ? $.extend({}, L, Q) : $.extend({}, Q, L)
        O = j(O)
        if (K) {
          O = O.replace(g, t)
        }
      }
      R = N[1] + (K ? C : O || !N[1] ? "?" : "") + O + M
    } else {
      R = P(I !== h ? I : location.href)
    }
    return R
  }
  a[B] = D(f, 0, q)
  a[F] = c = D(f, 1, o)
  a.sorted = j = function (J, K) {
    var I = [],
      L = {}
    $.each(a(J, K).split("&"), function (P, M) {
      var O = M.replace(/(?:%5B|=).*$/, ""),
        N = L[O]
      if (!N) {
        N = L[O] = []
        I.push(O)
      }
      N.push(M)
    })
    return $.map(I.sort(), function (M) {
      return L[M]
    }).join("&")
  }
  c.noEscape = function (J) {
    J = J || ""
    var I = $.map(J.split(""), encodeURIComponent)
    g = new RegExp(I.join("|"), "g")
  }
  c.noEscape(",/")
  c.ajaxCrawlable = function (I) {
    if (I !== h) {
      if (I) {
        u = /^.*(?:#!|#)/
        H = /^([^#]*)(?:#!|#)?(.*)$/
        C = "#!"
      } else {
        u = /^.*#/
        H = /^([^#]*)#?(.*)$/
        C = "#"
      }
      i = !!I
    }
    return i
  }
  c.ajaxCrawlable(0)
  $.deparam = m = function (L, I) {
    var K = {},
      J = { true: !0, false: !1, null: null }
    $.each(L.replace(/\+/g, " ").split("&"), function (O, T) {
      var N = T.split("="),
        S = t(N[0]),
        M,
        R = K,
        P = 0,
        U = S.split("]["),
        Q = U.length - 1
      if (/\[/.test(U[0]) && /\]$/.test(U[Q])) {
        U[Q] = U[Q].replace(/\]$/, "")
        U = U.shift().split("[").concat(U)
        Q = U.length - 1
      } else {
        Q = 0
      }
      if (N.length === 2) {
        M = t(N[1])
        if (I) {
          M =
            M && !isNaN(M) ? +M : M === "undefined" ? h : J[M] !== h ? J[M] : M
        }
        if (Q) {
          for (; P <= Q; P++) {
            S = U[P] === "" ? R.length : U[P]
            R = R[S] =
              P < Q ? R[S] || (U[P + 1] && isNaN(U[P + 1]) ? {} : []) : M
          }
        } else {
          if ($.isArray(K[S])) {
            K[S].push(M)
          } else {
            if (K[S] !== h) {
              K[S] = [K[S], M]
            } else {
              K[S] = M
            }
          }
        }
      } else {
        if (S) {
          K[S] = I ? h : ""
        }
      }
    })
    return K
  }
  function A(K, I, J) {
    if (I === h || typeof I === "boolean") {
      J = I
      I = a[K ? F : B]()
    } else {
      I = G(I) ? I.replace(K ? u : p, "") : I
    }
    return m(I, J)
  }
  m[B] = D(A, 0)
  m[F] = y = D(A, 1)
  $[z] ||
    ($[z] = function (I) {
      return $.extend(E, I)
    })({
      a: l,
      base: l,
      iframe: w,
      img: w,
      input: w,
      form: "action",
      link: l,
      script: w,
    })
  k = $[z]
  function v(L, J, K, I) {
    if (!G(K) && typeof K !== "object") {
      I = K
      K = J
      J = h
    }
    return this.each(function () {
      var O = $(this),
        M = J || k()[(this.nodeName || "").toLowerCase()] || "",
        N = (M && O.attr(M)) || ""
      O.attr(M, a[L](N, K, I))
    })
  }
  $.fn[B] = D(v, B)
  $.fn[F] = D(v, F)
  b.pushState = s = function (L, I) {
    if (G(L) && /^#/.test(L) && I === h) {
      I = 2
    }
    var K = L !== h,
      J = c(location.href, K ? L : {}, K ? I : 2)
    location.href = J
  }
  b.getState = x = function (I, J) {
    return I === h || typeof I === "boolean" ? y(I) : y(J)[I]
  }
  b.removeState = function (I) {
    var J = {}
    if (I !== h) {
      J = x()
      $.each($.isArray(I) ? I : arguments, function (L, K) {
        delete J[K]
      })
    }
    s(J, 2)
  }
  e[d] = $.extend(e[d], {
    add: function (I) {
      var K
      function J(M) {
        var L = (M[F] = c())
        M.getState = function (N, O) {
          return N === h || typeof N === "boolean" ? m(L, N) : m(L, O)[N]
        }
        K.apply(this, arguments)
      }
      if ($.isFunction(I)) {
        K = I
        return J
      } else {
        K = I.handler
        I.handler = J
      }
    },
  })
})(jQuery, this)
/*
 * jQuery hashchange event - v1.3 - 7/21/2010
 * http://benalman.com/projects/jquery-hashchange-plugin/
 *
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
;(function ($, e, b) {
  var c = "hashchange",
    h = document,
    f,
    g = $.event.special,
    i = h.documentMode,
    d = "on" + c in e && (i === b || i > 7)
  function a(j) {
    j = j || location.href
    return "#" + j.replace(/^[^#]*#?(.*)$/, "$1")
  }
  $.fn[c] = function (j) {
    return j ? this.bind(c, j) : this.trigger(c)
  }
  $.fn[c].delay = 50
  g[c] = $.extend(g[c], {
    setup: function () {
      if (d) {
        return false
      }
      $(f.start)
    },
    teardown: function () {
      if (d) {
        return false
      }
      $(f.stop)
    },
  })
  f = (function () {
    var j = {},
      p,
      m = a(),
      k = function (q) {
        return q
      },
      l = k,
      o = k
    j.start = function () {
      p || n()
    }
    j.stop = function () {
      p && clearTimeout(p)
      p = b
    }
    function n() {
      var r = a(),
        q = o(m)
      if (r !== m) {
        l((m = r), q)
        $(e).trigger(c)
      } else {
        if (q !== m) {
          location.href = location.href.replace(/#.*/, "") + q
        }
      }
      p = setTimeout(n, $.fn[c].delay)
    }
    ;(navigator.appName == "Microsoft Internet Explorer" ? true : false) &&
      !d &&
      (function () {
        var q, r
        j.start = function () {
          if (!q) {
            r = $.fn[c].src
            r = r && r + a()
            q = $('<iframe tabindex="-1" title="empty"/>')
              .hide()
              .one("load", function () {
                r || l(a())
                n()
              })
              .attr("src", r || "javascript:0")
              .insertAfter("body")[0].contentWindow
            h.onpropertychange = function () {
              try {
                if (event.propertyName === "title") {
                  q.document.title = h.title
                }
              } catch (s) {}
            }
          }
        }
        j.stop = k
        o = function () {
          return a(q.location.href)
        }
        l = function (v, s) {
          var u = q.document,
            t = $.fn[c].domain
          if (v !== s) {
            u.title = h.title
            u.open()
            t && u.write('<script>document.domain="' + t + '"</script>')
            u.close()
            q.location.hash = v
          }
        }
      })()
    return j
  })()
})(jQuery, this)
