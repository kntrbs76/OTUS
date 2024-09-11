variable "access" {
  type = map(any)
  default = {
    token     = "****************"
    cloud_id  = "*************"
    folder_id = "**************"
    zone      = "ru-central1-b"
  }
}

variable "data" {
  type = map(any)
  default = {
    count   = 3
    account = "kntrbs"
  }
}