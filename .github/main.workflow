workflow "New workflow" {
  on = "push"
  resolves = ["meedamian/sync-readme"]
}

action "meedamian/sync-readme" {
  uses = "meedamian/sync-readme"
}
