/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

export const getPages = () => {
  const r = require.context("../pages", false, /^.*\.js$/)

  return r.keys().map((key) => ({
    name: key.replace(/\.\/(.+)\.js/, "$1"),
    component: r(key).default,
  }))
}
