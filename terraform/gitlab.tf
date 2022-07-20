resource "yandex_compute_instance" "gitlab" {
  name     = "gitlab"
  hostname = "gitlab.bitrixdemo24.ru"

  resources {
    cores  = 6 ##4 gitlab что-то подтупливает порой, добавлю ему ресурсов
    memory = 6 ##4 gitlab что-то подтупливает порой, добавлю ему ресурсов
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fte6bebi857ortlja"
      size     = 50##12 gitlab что-то подтупливает порой, добавлю ему ресурсов
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}