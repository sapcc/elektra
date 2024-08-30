import React, { useMemo, useState } from "react"
import { Stack, Pagination } from "@cloudoperators/juno-ui-components"

const PaginationComp = ({
  count,
  limit,
  onChanged,
  isFetching,
  disabled,
  currentPage,
}) => {
  count = useMemo(() => {
    if (!count) return 0
    return count
  }, [count])

  limit = useMemo(() => {
    if (!limit) return 20
    return limit
  }, [limit])

  const pages = useMemo(() => {
    return Math.ceil(count / limit)
  }, [count, limit])

  const onPrevChanged = () => {
    if (currentPage < 1) return
    onChanged(currentPage - 1)
  }

  const onNextChanged = () => {
    if (currentPage === pages) return
    onChanged(currentPage + 1)
  }

  const onPageInputChanged = (page) => {
    //todo implement this functionality
  }

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
          isFirstPage={currentPage === 1}
          isLastPage={currentPage === pages}
        />
      </Stack>
    </>
  )
}

export default PaginationComp
