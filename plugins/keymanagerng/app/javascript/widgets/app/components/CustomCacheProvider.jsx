import React, { useEffect, useRef, useState } from "react"
import { CacheProvider } from "@emotion/react"
import createCache from "@emotion/cache"

const CustomCacheProvider = ({ children }) => {
  const ref = useRef()
  const [cache, setCache] = useState()

  useEffect(() => {
    setCache(
      createCache({
        container: ref.current.parentElement,
        key: "emotion-cache",
        prepend: false,
      })
    )
  }, [])

  return (
    <>
      {cache ? (
        <CacheProvider value={cache}>{children}</CacheProvider>
      ) : (
        <div ref={ref} />
      )}
    </>
  )
}

export default CustomCacheProvider
