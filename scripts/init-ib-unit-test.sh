#!/bin/bash
set -euo pipefail

IB_PATH="/w/build/unit/ib"
CONFIG_PATH="/w/build/unit/xml"
TESTS_PATH="/w/build/unit/test"
YAXUNIT_CFE="/w/tools/YAxUnit.cfe"

echo "▶️  Creating IB and importing XML..."
/opt/1cv8/current/ibcmd infobase create --db-path="$IB_PATH" --import="$CONFIG_PATH" --apply --force

echo "▶️  Creating Tests extension..."
/opt/1cv8/current/ibcmd infobase config extension create  \
  --db-path="$IB_PATH" --name=Tests --name-prefix="ОМ_"

echo "▶️  Importing Tests extension..."
/opt/1cv8/current/ibcmd infobase config import \
  --db-path="$IB_PATH" --extension=Tests "$TESTS_PATH"

echo "▶️  Applying Tests extension..."
/opt/1cv8/current/ibcmd infobase config apply \
  --db-path="$IB_PATH" --extension=Tests --force

echo "▶️  Updating Tests extension..."
/opt/1cv8/current/ibcmd infobase config extension update \
  --db-path="$IB_PATH" --name=Tests --safe-mode=no --unsafe-action-protection=no

echo "▶️  Loading YAXUNIT extension..."
/opt/1cv8/current/ibcmd infobase config load \
  --db-path="$IB_PATH" --extension=YAXUNIT --force "$YAXUNIT_CFE"

echo "▶️  Applying YAXUNIT extension..."
/opt/1cv8/current/ibcmd infobase config apply \
  --db-path="$IB_PATH" --extension=YAXUNIT --force

echo "▶️  Updating YAXUNIT extension..."
/opt/1cv8/current/ibcmd infobase config extension update \
  --db-path="$IB_PATH" --name=YAXUNIT --safe-mode=no --unsafe-action-protection=no

echo "✅ ibcmd operations completed successfully."

