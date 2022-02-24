# TODO: Define the variable for aws_region
variable "aws_creadentials" {
 default = "udacity"   
}
variable "aws_region" {
  default = "us-east-1"
}
variable "lambda_name" {
  default = "lambda"
}
variable "lambda_source_path" {
  default = "lambda.zip"
}