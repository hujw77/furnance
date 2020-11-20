#!/usr/bin/env bash

set -e

if [ "$FNC_VERBOSE" ]; then set -x; fi

export SETH_CHAIN=${SETH_CHAIN-ropsten}

if ! [[ $SETH_INIT ]]; then
  export SETH_INIT=1
  # shellcheck source=/dev/null
  [[ -e ~/.sethrc ]] && . ~/.sethrc
  # shellcheck source=/dev/null
  [[ -e $XDG_CONFIG_HOME/seth/sethrc ]] && . "$XDG_CONFIG_HOME"/seth/sethrc
  # shellcheck source=/dev/null
  [[ $(pwd) != ~ && -e .sethrc ]] && . .sethrc
fi

[[ $(pwd) != ~ && -e .fncrc ]] && . .fncrc

config-init() {
  path=${FNC_CONFIG:-$1}
  if [[ ! -e "$path" ]]; then
    echo "Config file not found: $path not found"
    exit 1
  fi
  exports=$(cat $path | jq -r ".deploy_data // . | \
    to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
  for e in $exports; do export "$e"; done
}

fnc-init() {
  if [[ "$SETH_CHAIN" ]]; then  
    case "$SETH_CHAIN" in
      mainnet)
        config-init "${0%/*}/conf/mainnet.json";
        rpc-verify
        chain-verify "1"
        ;;
      ropsten)
        config-init "${PWD}/${0%/*}/conf/ropsten.json";
        rpc-verify
        chain-verify "3"
        ;;
      kovan)
        config-init "${0%/*}/conf/kovan.json";
        rpc-verify
        chain-verify "42"
        ;;
      testnet) # local dapp testnet
        config-init "${FNC_CONFIG:-$TESTNET/8545/config/addresses.json}"
        export ETH_RPC_URL="${ETH_RPC_URL:-http://127.0.0.1:8545}"
        export ETH_LOGS_API="${ETH_LOGS_API:-rpc}"
        export ETH_KEYSTORE="${ETH_KEYSTORE:-$TESTNET/8545/keystore}"
        export ETH_PASSWORD="${ETH_PASSWORD:-/dev/null}"
        from="$(seth accounts ls | sed 1q | awk '{print substr ($0, 0, 42)}')"
        export ETH_FROM="${ETH_FROM:-$from}"
        ;;
      *)
        if [[ "$@" != *"help"* ]]; then
          echo "Warning: \`--chain' option not specified. Defaulting to ropsten"
          config-init "${0%/*}/conf/ropsten.json";
          export SETH_CHAIN=ropsten
        fi
    esac
  fi
}

rpc-verify() {
  if test -z "$ETH_RPC_URL"
  then
    echo "Please set the ETH_RPC_URL to an ethereum endpoint."
    exit 1
  fi
}

chain-verify() {
  EXPECTED="$1"
  ACTUAL="$(seth rpc net_version)"
  if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "Ethereum network version is incorrect."
    echo "Verify ETH_RPC_URL is set to $FNC_CHAIN (Expected $EXPECTED, got $ACTUAL)"
    exit 1
  fi
}

if ! [[ $FNC_INIT ]]; then
  TESTNET="${TESTNET:-~/.dapp/testnet}"
  export FNC_INIT=1
  fnc-init
fi
