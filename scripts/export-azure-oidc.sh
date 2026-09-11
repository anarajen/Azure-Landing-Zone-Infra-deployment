#!/usr/bin/env bash
set -euo pipefail

: "${servicePrincipalId:?servicePrincipalId not available}"
: "${tenantId:?tenantId not available}"
: "${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID:?Service connection ID not available}"

export ARM_USE_OIDC=true
export ARM_USE_AZUREAD=true

export ARM_CLIENT_ID="$servicePrincipalId"
export ARM_TENANT_ID="$tenantId"
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

export ARM_OIDC_AZURE_SERVICE_CONNECTION_ID="$AZURESUBSCRIPTION_SERVICE_CONNECTION_ID"

echo "Terraform OIDC context:"
echo "subscription=$ARM_SUBSCRIPTION_ID"
echo "tenant=$ARM_TENANT_ID"
echo "client=$ARM_CLIENT_ID"