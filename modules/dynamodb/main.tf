resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name                        = "GameScores"
  billing_mode                = "PROVISIONED"
  read_capacity               = 10
  write_capacity              = 10
  hash_key                    = "UserId"
  range_key                   = "GameTitle"
  deletion_protection_enabled = true

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "test"
  }
}


resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.basic_dynamodb_table.name
  hash_key   = aws_dynamodb_table.basic_dynamodb_table.hash_key
  range_key  = aws_dynamodb_table.basic_dynamodb_table.range_key

  item = <<ITEM
{
  "UserId": {"S": "9f2d7c4a-8e3b-4b09-91f1-3c5a7d2e7e4f"},
  "GameTitle": {"S": "FarCry 3"},
  "YearReleased": {"N": "2009"},
  "Genre": {"S": "Action"}
}
ITEM
}
