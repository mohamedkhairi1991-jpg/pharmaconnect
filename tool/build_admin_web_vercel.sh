#!/usr/bin/env bash
set -euo pipefail

: "${APP_ENVIRONMENT:?APP_ENVIRONMENT is required}"
: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY is required}"
: "${ADMIN_AUTH_CALLBACK_URL:?ADMIN_AUTH_CALLBACK_URL is required}"

flutter_dir="${TMPDIR:-/tmp}/pharamty-flutter-3.44.2"

git clone \
  --branch 3.44.2 \
  --depth 1 \
  https://github.com/flutter/flutter.git \
  "${flutter_dir}"

export PATH="${flutter_dir}/bin:${PATH}"

flutter config --enable-web
flutter pub get

cd apps/admin
flutter build web \
  --release \
  --dart-define="APP_ENVIRONMENT=${APP_ENVIRONMENT}" \
  --dart-define="SUPABASE_URL=${SUPABASE_URL}" \
  --dart-define="SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}" \
  --dart-define="ADMIN_AUTH_CALLBACK_URL=${ADMIN_AUTH_CALLBACK_URL}"
