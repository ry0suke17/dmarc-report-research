#!/bin/bash

set -eu

DMARC_REPORT=${1:-""}

if [ -z ${DMARC_REPORT} ]; then
  echo 'Please set the "DMARC_REPORT" args and try again.' >&2
  exit 1
fi

report=$(yq -p xml -o json ${DMARC_REPORT})
src_org_name=$(echo ${report} | jq -r '.feedback.report_metadata.org_name')
src_date_begin=$(echo ${report} | jq -r '.feedback.report_metadata.date_range.begin')
src_date_end=$(echo ${report} | jq -r '.feedback.report_metadata.date_range.end')
date_begin=$(date -r ${src_date_begin} +"%Y-%m-%d %H:%M:%S")
date_end=$(date -r ${src_date_end} +"%Y-%m-%d %H:%M:%S")

echo "src_org_name	date_begin	date_end	source_ip	count	dkim	spf	country	org	region_name"

echo ${report} | jq -c '.feedback.record[]' | while read record; do
  source_ip=$(echo ${record} | jq -r '.row.source_ip')
  count=$(echo ${record} | jq -r '.row.count')
  dkim=$(echo ${record} | jq -r '.row.policy_evaluated.dkim')
  spf=$(echo ${record} | jq -r '.row.policy_evaluated.spf')

  # The free endpoint is limited to 45 requests / minute
  # ref. https://members.ip-api.com/
  sleep 1.5

  info=$(curl -s http://ip-api.com/json/${source_ip} | jq)
  country=$(echo ${info} | jq -r '.country')
  org=$(echo ${info} | jq -r '.org')
  region_name=$(echo ${info} | jq -r '.regionName')

  echo "${src_org_name}	${date_begin}	${date_end}	${source_ip}	${count}	${dkim}	${spf}	${country}	${org}	${region_name}"
done
