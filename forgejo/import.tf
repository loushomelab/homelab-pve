data "gitea_repo" "testcandy" {
  username = "Work"
  name     = "testcandy"
}

import {
  to = gitea_repository.testcandy
  id = data.gitea_repo.testcandy.id
}
