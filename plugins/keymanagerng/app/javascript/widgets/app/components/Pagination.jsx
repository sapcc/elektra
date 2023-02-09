import React, { useMemo, useState, useEffect } from "react"
import { Stack, Pagination } from "juno-ui-components"

const PaginationComp = ({
  count,
  limit,
  onChanged,
  isFetching,
  disabled,
  currentPage,
}) => {
  const [offset, setOffset] = useState(0)

  // useEffect(() => {
  //   if (onChanged && offset > 0) {
  //     onChanged(offset)
  //     // console.log("SECRETS_0: ", offset)
  //   }
  // }, [offset])

  count = useMemo(() => {
    if (!count) return 0
    return count
  }, [count])

  limit = useMemo(() => {
    if (!limit) return 10
    return limit
  }, [limit])

  const pages = useMemo(() => {
    return Math.ceil(count / limit)
  }, [count, limit])

  const onPrevChanged = () => {
    // console.log("onPrevChanged actualPage:", actualPage)
    if (currentPage < 1) return
    // setOffset(offset - limit)
    // setActualPage(actualPage - 1)
    onChanged(currentPage - 1)
  }

  const onNextChanged = () => {
    // console.log("onNext Before Changed actualPage:", actualPage)
    if (currentPage === pages) return
    // setOffset(offset + limit)
    // setActualPage(actualPage + 1)
    onChanged(currentPage + 1)
  }
  // console.log("onNext After Changed actualPage:", actualPage)

  const onPageInputChanged = (page) => {
    //TODO: update offset and limit
    // setActualPage(page)
  }

  useEffect(() => {
    // console.log("pagination component")
  })
  // console.log("Limit:", limit)
  return (
    <>
      <Stack alignment="center" className="mt-4" distribution="end">
        {isFetching ? <span> Loading...</span> : null}{" "}
        <Pagination
          className="tw-mt-4"
          distribution="end"
          currentPage={currentPage}
          onKeyPress={onPageInputChanged}
          onPressNext={onNextChanged}
          onPressPrevious={onPrevChanged}
          pages={pages}
          variant="input"
        />
      </Stack>
    </>
  )
}

export default PaginationComp
