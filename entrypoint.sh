#!/bin/bash
exec ./eclipse -data "${WORKSPACE:-/workspace}" "$@"

