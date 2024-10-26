# variables for cider range
variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# give project a name
variable "project" {
  type    = string
  default = "wordpress_apache"

}

# launch template ami
variable "ami" {
  type    = string
  default = "ami-07355fe79b493752d"

}