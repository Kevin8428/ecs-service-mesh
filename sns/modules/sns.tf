resource "aws_sns_topic" "topic" {
  name = var.name
}

resource "aws_sns_topic_policy" "sns_privs" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.topic_policy.json
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    resources = [aws_sns_topic.topic.arn]
  }
}