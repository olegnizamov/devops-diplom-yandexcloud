terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }


  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "diplom-olegnizamov"
    region     = "ru-central1"
    key        = "./prod/state.tfstate"
    access_key = "*********"
    secret_key = "*********"


    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "*********"
  cloud_id                 = "b1gtitubqcoaoesmi8vd"
  folder_id                = "b1gvcj5c7qi25j81c8ob"
  zone      = "ru-central1-a"
}



