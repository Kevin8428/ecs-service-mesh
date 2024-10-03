resource "aws_sqs_queue" "queue" {
  name = var.name
}

resource "aws_sqs_queue_policy" "policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "allowsns",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": ["${var.sns_arn}"]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "subscribe" {
  topic_arn            = var.sns_arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.queue.arn
  raw_message_delivery = true
}
