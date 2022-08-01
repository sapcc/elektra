import { createAjaxHelper } from "lib/ajax_helper"
import { widgetBasePath } from "lib/widget"

const baseURL = widgetBasePath("testikus")
export default createAjaxHelper({ baseURL })
