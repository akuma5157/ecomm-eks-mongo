data "aws_iam_policy_document" "cicd" {
  statement {
    sid = "0"
    effect = "Allow"
    actions = [
      "ecr:*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cicd-trust" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_policy" "cicd-policy" {
  name = "${var.name}-cicd-policy"
  description = "for ${var.name} jenkins server"
  policy = data.aws_iam_policy_document.cicd.json
}

resource "aws_iam_role" "cicd-role" {
  name = "${var.name}-cicd"
  assume_role_policy = data.aws_iam_policy_document.cicd-trust.json
}

resource "aws_iam_role_policy_attachment" "cicd" {
  policy_arn = aws_iam_policy.cicd-policy.arn
  role = aws_iam_role.cicd-role.name
}

resource "aws_iam_instance_profile" "cicd-profile" {
  name = "${var.name}-cicd-profile"
  role = aws_iam_role.cicd-role.name
}
