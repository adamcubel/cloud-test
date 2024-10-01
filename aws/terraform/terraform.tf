terraform {
  backend "s3" {
    bucket = "TF STATE BUCKET NAME"
    key    = "FOLDER/FILE NAME"
    region = "us-east-1"
  }
}
