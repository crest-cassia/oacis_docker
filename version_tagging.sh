#!/usr/bin/env bash
# Multi-arch build & push for oacis/oacis
# Usage:
#   OACIS_VERSION=v4.0.0 ./version_tagging.sh
#   (Override with environment variables: IMAGE, PLATFORMS)

set -euo pipefail
IFS=$'\n\t'

# ====== Config ======
IMAGE="${IMAGE:-oacis/oacis}"
# NOTE: the corresponding tag must exist on https://github.com/crest-cassia/oacis
#       (git clone fails loudly otherwise)
OACIS_VERSION="${OACIS_VERSION:-v4.0.0}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
BUILDER_NAME="${BUILDER_NAME:-oacis-multi}"
# QEMU version used for cross-arch emulation. Pin a known-good release:
# recent qemu builds sporadically segfault gcc during amd64-under-arm64 builds.
BINFMT_IMAGE="${BINFMT_IMAGE:-tonistiigi/binfmt:qemu-v8.1.5}"

# ====== Helpers ======
log() { printf '[%s] %s\n' "$(date +'%F %T')" "$*" >&2; }

# ====== Login (if needed) ======
if ! docker info >/dev/null 2>&1; then
  log "Docker is not running. Please start Docker before running this script."
  exit 1
fi

if ! docker system info 2>/dev/null | grep -q 'Username:'; then
  log "Running docker login (skip if already logged in)"
  docker login
fi

# ====== QEMU/binfmt (needed on Linux hosts; usually not needed on Docker Desktop for macOS) ======
# Do not fail if this step fails (may not be required in some environments)
if docker info --format '{{.OSType}}' | grep -qi linux; then
  log "Setting up binfmt (QEMU) for Linux host - continuing even if it fails"
  docker run --privileged --rm "${BINFMT_IMAGE}" --install all || true
fi

# ====== Prepare buildx builder ======
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
  log "Creating buildx builder '${BUILDER_NAME}'"
  docker buildx create --name "${BUILDER_NAME}" --driver docker-container
fi

# Set as default builder and bootstrap
docker buildx use "${BUILDER_NAME}"
docker buildx inspect --bootstrap >/dev/null

# ====== Build context ======
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}/oacis"

# ====== Build & Push (create multi-arch manifest with the same tags) ======
# Pre-releases (tags containing "-rc") are pushed under their own tag only,
# so that "latest" keeps pointing to the newest stable release.
TAG_ARGS=(-t "${IMAGE}:${OACIS_VERSION}")
if [[ "${OACIS_VERSION}" != *-rc* ]]; then
  TAG_ARGS+=(-t "${IMAGE}:latest")
else
  log "Pre-release version detected (${OACIS_VERSION}); skipping the 'latest' tag"
fi

log "Building and pushing ${IMAGE}:${OACIS_VERSION} (${PLATFORMS})"
docker buildx build \
  --platform "${PLATFORMS}" \
  "${TAG_ARGS[@]}" \
  --build-arg "OACIS_VERSION=${OACIS_VERSION}" \
  --push .

# ====== Inspect ======
log "Inspecting pushed manifest:"
docker buildx imagetools inspect "${IMAGE}:${OACIS_VERSION}" || true
if [[ "${OACIS_VERSION}" != *-rc* ]]; then
  docker buildx imagetools inspect "${IMAGE}:latest" || true
fi

log "Done. The pulled platform will automatically match the client's architecture (amd64/arm64)."

