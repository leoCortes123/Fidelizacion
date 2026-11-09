#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
graphify .
# Versionar solo el reporte resumen
git add graphify-out/GRAPH_REPORT.md
echo "Grafo regenerado. Revisa y commitea GRAPH_REPORT.md."
