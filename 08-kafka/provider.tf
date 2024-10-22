locals {
  cloud_id  = "b1gpitn05phdb16ou71p"
  zone = "ru-central1-b"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = local.cloud_id
  #folder_id = local.folder_id
}
