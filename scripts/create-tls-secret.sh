#!/usr/bin/env bash

NAMESPACE="$1"
SECRET_NAME="$2"

if [[ -z "${PRIVATE_KEY}" ]] || [[ -z "${CERT}" ]]; then
  echo "PRIVATE_KEY and CERT values must be provided as environment variables"
  exit 1
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR=".tmp/sealed-secrets"
fi
mkdir -p "${TMP_DIR}"

PRIVATE_KEY_FILE="${TMP_DIR}/private.key"
CERT_FILE="${TMP_DIR}/cert.key"

echo "${PRIVATE_KEY}" > "${PRIVATE_KEY_FILE}"
echo "${CERT}" > "${CERT_FILE}"

kubectl create secret tls "${SECRET_NAME}" --cert="${CERT_FILE}" --key="${PRIVATE_KEY_FILE}" --dry-run=client -o yaml | \
  kubectl label -f - sealedsecrets.bitnami.com/sealed-secrets-key=active --local=true --dry-run=client -o yaml | \
  kubectl create -n "${NAMESPACE}" -f -
