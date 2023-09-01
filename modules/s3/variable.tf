variable "log_bucket_name" {
  description = "bucket name for storage log"
  default = ""
}

variable "s3_bucket_name" {
  description = "name for bucket must be unique"
  default = ""
}

variable "acl" {
  description = "acesss control list"
  default = "private"
}

variable "force_destroy" {
  description = "force destroy"
  default = true
}
variable "versioning" {
  description = "enable versioning"
  default = true
}
variable "tags" {
  default =  {
    Name        = "Example Bucket"
    Environment = "Production"
  }
}
variable "website" {
  default = {
    index_document = "index.html"
    error_document = "error.html"
  }
}

variable "cors_rule" {
  default = {   
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


variable "server_side_encryption_configuration" {
  default = {
        rule = {
      apply_server_side_encryption_by_default ={
        sse_algorithm = "AES256"
      }
    }
  }
}