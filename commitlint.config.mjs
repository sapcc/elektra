// import config from "./.github/commit-config.js"

export const types = ["build", "chore", "fix", "feat", "refactor", "research", "style", "test"]
export const scopes = [
  "build",
  "config",
  "ci",
  "core",
  "docs",
  "deps",
  "infra",
  "ui",
  "version",
  "access_profile",
  "audit",
  "automation",
  "block_storage",
  "cloudops",
  "compute",
  "dns_service",
  "email_service",
  "identity",
  "image",
  "inquiry",
  "keppel",
  "key_manager",
  "kubernetes",
  "lbaas",
  "lookup",
  "masterdata_cockpit",
  "metrics",
  "networking",
  "object_storage",
  "reports",
  "resources",
  "shared_filesystem_storage",
  "tools",
  "webconsole",
  /^ISSUE-\d+$/, // Regex pattern for ISSUE-<number>]
]

export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [2, "always", types], // Enforces the type to be one of the specified values
    "scope-enum": [2, "always", scopes],
    "scope-case": [2, "always", "kebab-case"], // Enforces kebab-case
    "subject-case": [
      2,
      "never",
      ["start-case", "pascal-case", "upper-case"], // Disallows certain cases for the subject
    ],
  },
}
