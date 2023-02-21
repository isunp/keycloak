resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  tags                 = var.tags
}

resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = var.repository_name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep image deployed with tag '${var.tags}''",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["${var.tags}"],
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 2 any images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

}
