#!/bin/bash

BLUESKY_HANDLE="..."
BLUESKY_PASSWORD="..."
BLUESKY_PDS_HOST="https://bsky.social"

CURL_OUTPUT_FILE=$( mktemp )
CURL_RESPONSE=$(
  curl \
    --request POST \
    --header "Content-type: application/json" \
    --location \
    --output "${CURL_OUTPUT_FILE}" \
    --show-error \
    --silent \
    --write-out "%{http_code}" \
    --url "${BLUESKY_PDS_HOST}/xrpc/com.atproto.server.createSession" \
    --data-raw "{\"identifier\":\"${BLUESKY_HANDLE}\",\"password\":\"${BLUESKY_PASSWORD}\"}"
)
if [[ "$CURL_RESPONSE" != "200" ]]; then
  echo "::group::"
  echo "::error::scripts/post.sh received $CURL_RESPONSE creating session:"
  cat "${CURL_OUTPUT_FILE}"
  echo "::endgroup::"

  # ERROR_MSG="could not create session"
  # echo "ERROR_MSG=${ERROR_MSG}" >> $GITHUB_ENV

  rm "${CURL_OUTPUT_FILE}"
  exit 1
fi

CREATE_SESSION_JSON=$( cat "${CURL_OUTPUT_FILE}" )
rm "${CURL_OUTPUT_FILE}"
if [[ -z "${CREATE_SESSION_JSON}" ]]; then
  echo "::group::"
  echo "::error::scripts/post.sh received empty response creating session"
  echo "::endgroup::"

  # ERROR_MSG="JSON from creating session is empty"
  # echo "ERROR_MSG=${ERROR_MSG}" >> $GITHUB_ENV

  exit 1
fi
# echo "${CREATE_SESSION_JSON}"

ACCESS_JWT=$( echo "${CREATE_SESSION_JSON}" | jq -r '.accessJwt' )
# REFRESH_JWT=$( echo "${CREATE_SESSION_JSON}" | jq -r '.refreshJwt' )

# echo "access JWT:  ${ACCESS_JWT}"
# echo "refresh JWT: ${REFRESH_JWT}"

NOW=$( date -u +'%FT%TZ' )
# echo "${NOW}"

CURL_OUTPUT_FILE=$( mktemp )
CURL_RESPONSE=$(
  curl \
    --request POST \
    --header "Authorization: Bearer ${ACCESS_JWT}" \
    --header "Content-type: application/json" \
    --location \
    --output "${CURL_OUTPUT_FILE}" \
    --show-error \
    --silent \
    --write-out "%{http_code}" \
    --url "${BLUESKY_PDS_HOST}/xrpc/com.atproto.repo.createRecord" \
    --data-raw "{\"repo\":\"${BLUESKY_HANDLE}\",\"collection\":\"app.bsky.feed.post\",\"record\":{\"text\":\"*ping*\",\"createdAt\":\"${NOW}\"}}"
)
if [[ "$CURL_RESPONSE" != "200" ]]; then
  echo "::group::"
  echo "::error::scripts/post.sh received $CURL_RESPONSE creating record:"
  cat "${CURL_OUTPUT_FILE}"
  echo "::endgroup::"

  # ERROR_MSG="could not create record"
  # echo "ERROR_MSG=${ERROR_MSG}" >> $GITHUB_ENV

  rm "${CURL_OUTPUT_FILE}"
  exit 1
fi

CREATE_RECORD_JSON=$( cat "${CURL_OUTPUT_FILE}" )
rm "${CURL_OUTPUT_FILE}"
if [[ -z "${CREATE_RECORD_JSON}" ]]; then
  echo "::group::"
  echo "::error::scripts/post.sh received empty response creating record"
  echo "::endgroup::"

  # ERROR_MSG="JSON from creating record is empty"
  # echo "ERROR_MSG=${ERROR_MSG}" >> $GITHUB_ENV

  exit 1
fi
echo "${CREATE_RECORD_JSON}"
