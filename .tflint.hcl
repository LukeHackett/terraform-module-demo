tflint {
  required_version = ">= 0.54"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

#
# rule "aws_resource_missing_tags" {
#   enabled = true
#   tags = ["Foo", "Bar"]
#   exclude = [] # (Optional) Exclude some resource types from tag checks
# }