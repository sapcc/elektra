# How to contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Code reviews

All submissions require review. We use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Pull request guidelines

- `Add a description`. Keep the person who is going to be reviewing the PR in mind. You are making their life easier when your description is formed in a way that brings them up to speed with minimum information.
- `NO large PRs if possible`. Unless there is a specific technical reason that makes it impossible to split a large commit into multiple steps keep PRs small. It’s much easier to review smaller pull requests than go through hundreds of file changes in a single one. The larger the pull request, the higher is the chance of missing a bug or an edge case. Additionally, smaller pull requests get reviewed faster and are easier to merge since there tend to be less conflicts.
- `NO PRs cross contexts allowed`. If you submit a PR where different contexts are being used it is hard for the reviewer to understand the changes and the he higher is the chance of missing a bug or an edge case.
- `ONLY formatted/prettified code allowed`. If the code is not prettified ore formatted correctly any change from a colleague on the same file with a prettifier installed will change the whole file hiding the actual change.
- `NO code chunks commented allowed`. If there are code chunks commented over the place makes it harder to follow the code. Description and links to documentation are very welcome. If no code is being used please remove it. You will find the code again in github history.
- `NO sensitive data allowed in github.com`. Please private data, endpoints, user IDs, Passwords… actually everything which is PCI relevant can’t be committed.
- `NO log of sensitive data`. It is not allowed to log sensitive data as user IDs, passwords, etc. since it is also no PCI compliant.
