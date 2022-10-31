# Optional - Only necessary if you want a full Amplify App running in AWS (not just localhost)

resource "aws_codecommit_repository" "tca_codecommit_repo" {
  count           = var.tca_create_codecommit_repo ? 1 : 0
  repository_name = var.tca_codecommit_repo_name
  description     = var.tca_codecommit_repo_description
  default_branch  = var.tca_codecommit_repo_default_branch

  tags = merge(
    {
      "AppName" = var.app_name
    },
    var.tags,
  )
}
