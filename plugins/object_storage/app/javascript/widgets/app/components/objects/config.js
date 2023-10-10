import { Unit } from "lib/unit"

const unit = new Unit("B")
export const LIMIT = unit.parse("5Mib") // Bytes
