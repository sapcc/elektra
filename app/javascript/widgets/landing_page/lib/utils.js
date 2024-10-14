/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Returns a hash code for a string.
 * (Compatible to Java's String.hashCode())
 *
 * The hash code for a string object is computed as
 *     s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
 * using number arithmetic, where s[i] is the i th character
 * of the given string, n is the length of the string,
 * and ^ indicates exponentiation.
 * (The hash value of the empty string is zero.)
 *
 * @param {string} s a string
 * @return {number} a hash code value for the given string.
 */
export const hashCode = (s) => {
  var h = 0,
    l = s.length,
    i = 0
  if (l > 0) while (i < l) h = ((h << 5) - h + s.charCodeAt(i++)) | 0
  return h
}

export const buildDashboardLink = (region, domain, prodMode) => {
  if (prodMode) {
    return `https://dashboard.${region?.toLowerCase()}.cloud.sap/${domain?.toLowerCase()}/home`
  } else {
    const currentLocation = new URL(window.location.href)
    currentLocation.pathname = `${domain?.toLowerCase()}/home`
    return currentLocation.href
  }
}

export const buildPasswordLoginLink = (region, domain, prodMode) => {
  if (prodMode) {
    return `https://dashboard.${region?.toLowerCase()}.cloud.sap/${domain?.toLowerCase()}/auth/login/${domain?.toLowerCase()}?after_login=%2F${domain?.toLowerCase()}%2Fhome`
  } else {
    const currentLocation = new URL(window.location.href)
    currentLocation.pathname = `/${domain?.toLowerCase()}/auth/login/${domain?.toLowerCase()}`
    currentLocation.search = `?after_login=%2F${domain?.toLowerCase()}%2Fhome`
    return currentLocation.href
  }
}
