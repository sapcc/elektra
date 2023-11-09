export const getSecretUuid = function (secret) {
  const secretUuidMatch = secret.secret_ref.match(/^.*secrets\/(.+)$/)
  return secretUuidMatch && secretUuidMatch[1]
}
