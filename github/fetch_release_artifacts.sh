#!/usr/bin/env bash

set -euo pipefail

# Connect to GitHub and download private repo artifacts for the tagged release
#
# Requires: curl & jq executables (jq to parse json)
# Requires: Fine-grained token with "Contents" read permission for this repo
#  or "Classic" with full "repo" permissions (Beware: gives access to all repos)

TOKEN="$1"

# The release tag
VERSION_TAG="${2:-latest}"  # tag name

# Repo owner (user id)
# OWNER="<ORGANIZATION_OR_USER>"  # TODO: set and uncomment
# Repo name
# REPO="<REPO_NAME>"  # TODO: set and uncomment

# "-s" silences and others come directly from examples at:
# https://docs.github.com/en/rest/releases/releases
JSON_ATTRIBUTES=("-s" \
  "-H" "Accept: application/vnd.github+json" \
  "-H" "Authorization: Bearer ${TOKEN}"\
  "-H" "X-GitHub-Api-Version: 2022-11-28" \
)

# Get the url for the specified release
RELEASE_URL="$(curl "${JSON_ATTRIBUTES[@]}" \
  "https://api.github.com/repos/${OWNER}/${REPO}/releases" \
  | jq '.[] | select(.tag_name | contains("'"${VERSION_TAG}"'"))' \
  | jq -r '.url')"


# Gets the "url" attribute for every one of the "assets" for specified release
ASSET_URLS="$( \
   curl "${JSON_ATTRIBUTES[@]}" "${RELEASE_URL}" | jq -r '.assets[] | .url')"
echo "Asset URLs: ${ASSET_URLS}"


for URL in ${ASSET_URLS} ; do
  FILE_NAME="$(curl "${JSON_ATTRIBUTES[@]}" "${URL}" | jq -r '.name')"
  echo -e "\nDeleting ${FILE_NAME} if it exists, then downloading it..."
  # curl does not allow overwriting file from -O, nuke
  rm -f "${FILE_NAME}"

  # curl:
  # -O: Use name provided from endpoint
  # -J: "Content Disposition" header, in this case "attachment"
  # -L: Follow links because this request gets forwarded
  # -H "Accept: application/octet-stream": Tells API to download full binary
  curl -O -J -L \
    -H "Accept: application/octet-stream" \
    -H "Authorization: Bearer ${TOKEN}"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${URL}"
done
