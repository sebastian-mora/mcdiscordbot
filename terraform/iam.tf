data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_instance_profile" "minecraft_server_role" {
  name = "minecraft-server-role"
  role = aws_iam_role.minecraft_server_role.name
}

resource "aws_iam_role" "minecraft_server_role" {
  name = "minecraft-server-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.minecraft_server_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.mc-worlds.arn}/*",
                "${aws_s3_bucket.mc-worlds.arn}",
                "${aws_s3_bucket.mc-server-files.arn}/*",
                "${aws_s3_bucket.mc-server-files.arn}",
                "${aws_dynamodb_table.mc-table.arn}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ec2:DescribeTags",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": [
                "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:mcalerts"
            ]
        },

        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:DescribeParameters"
            ],
            "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
        },

        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:aws/ssm"
         ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.minecraft_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}