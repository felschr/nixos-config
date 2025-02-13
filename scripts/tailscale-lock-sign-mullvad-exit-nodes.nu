#! /usr/bin/env nu

let $status = tailscale lock status --json | from json

let $nodes = $status | get FilteredPeers
let $nodes_mullvad = $nodes | where Name =~ ".mullvad.ts.net"

let count_total = $nodes | length
let count_mullvad = $nodes_mullvad | length

print $"unsigned nodes: ($count_total) total, ($count_mullvad) Mullvad"

if ($nodes_mullvad | length) == 0 {
  print "no Mullvad nodes need to be signed"
  return
}

print "signing Mullvad nodes..."

$nodes_mullvad | each { |node|
  print $"signing ($node.Name)"
  tailscale lock sign $node.NodeKey
  sleep 0.1sec
}

print "all Mullvad nodes successfully signed"
