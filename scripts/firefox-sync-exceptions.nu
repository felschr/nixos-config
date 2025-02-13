#! /usr/bin/env nu

print "This script synchronizes site data & cookie exceptions for Firefox-based browsers with a TOML config file."

let browsers = [
  { name: "Mullvad Browser" path: "~/.mullvad/mullvadbrowser" }
  { name: "Tor Browser" path: "~/.tor project/firefox" }
  { name: "Firefox" path: "~/.mozilla/firefox" }
]
let browser = $browsers | input list --display name --fuzzy "Select your browser"

print $"Looking for profiles in ($browser.path)"
let profiles = ls --short-names ...(glob $browser.path) | where type == "dir" | get name
let profile = $profiles | input list --fuzzy "Select the profile you want to change"

let db_file = $"($browser.path)/($profile)/permissions.sqlite"

let config_file = "/etc/nixos/home/browsers/site-data-exceptions.toml"
let config_file = input --default $config_file "Select your config file"

# get origin & origin attributes separately from single origin string
def split_origin []: string -> record {
  let x = $in | split column '^' origin attrs | into record
  let attrs = if $x.attrs? != null {
    $x.attrs | split row '&' | each {|attr| $attr | split row '='} | into record
  } else { {} }
  { origin: $in origin_short: $x.origin } | merge $attrs
}

let db = $db_file | open
let config = $config_file | open

let exceptions_db = $db | get moz_perms
  | where type == "cookie" and permission == 1 and expireType == 0 and expireTime == 0
  | each {|x| $x | merge ($x.origin | split_origin) }
let exceptions_config = $config | get $profile | each {|origin| $origin | split_origin }

let exceptions_to_insert = $exceptions_config
  | filter {|x| ($exceptions_db | where origin_short == $x.origin_short | length) == 0 }
  | each {|x| { origin: $x.origin } }

let exceptions_to_update = $exceptions_config
  | each {|x|
    let results = $exceptions_db | where origin_short == $x.origin_short and origin != $x.origin
    let result = $results.0?
    if $result != null {
      { id: $result.id origin: $x.origin origin_old: $result.origin }
    } else { null }
  }

let exceptions_to_delete = $exceptions_db
  | filter {|x| ($exceptions_config | where origin_short == $x.origin_short | length) == 0 }
  | each {|x| { id: $x.id origin: $x.origin } }

let needs_insert = ($exceptions_to_insert | length) > 0
let needs_update = ($exceptions_to_update | length) > 0
let needs_delete = ($exceptions_to_delete | length) > 0
let needs_changes = $needs_insert or $needs_update or $needs_delete

if $needs_changes == false {
  print "No changes neccessary"
  exit
}

mut available_actions = []

if $needs_insert {
  print "Exceptions to insert:"
  print $exceptions_to_insert
  $available_actions = $available_actions | append "insert"
}

if $needs_update {
  print "Exceptions to update:"
  print $exceptions_to_update
  $available_actions = $available_actions | append "update"
}

if $needs_delete {
  print "Exceptions to delete:"
  print $exceptions_to_delete
  $available_actions = $available_actions | append "delete"
}

let prompt = "Which of the changes above should be applied?"
let actions = $available_actions | input list --multi $prompt

if ($actions | length) > 0 {
  let time = (date now | into int) / 1000000 | into int

  if $needs_insert and "insert" in $actions {
    $exceptions_to_insert | each {|x|
      $db | query db '
        INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime)
        VALUES (:origin, "cookie", 1, 0, 0, :time)
      ' --params { origin: $x.origin time: $time }
    }
    print "Successfully inserted new records"
  }

  if $needs_update and "update" in $actions {
    $exceptions_to_update | each {|x|
      $db | query db '
        UPDATE moz_perms
        SET origin = :origin, modificationTime = :time
        WHERE id = :id
      ' --params { id: $x.id origin: $x.origin time: $time }
    }
    print "Successfully updated changed records"
  }

  if $needs_delete and "delete" in $actions {
    $exceptions_to_delete | each {|x|
      $db | query db 'DELETE FROM moz_perms WHERE id = :id' --params { id: $x.id }
    }
    print "Successfully deleted missing records"
  }
} else {
  print "Not applying any changes"
}
