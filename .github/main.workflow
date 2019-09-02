workflow "New workflow" {
  on = "push"
  resolves = ["meedamian/sync-readme"]
}

action "meedamian/sync-readme" {
  uses = "actions/bin/filter@25b7b846d5027eac3315b50a8055ea675e2abd89"
}
