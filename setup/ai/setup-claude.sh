#!/usr/bin/env bash
set -e

claude plugin marketplace add scaryrawr/scaryrawr-plugins || true

claude plugin install typescript-native-lsp || true
# claude plugin install chrome-devtools
claude plugin install azure-devops || true
