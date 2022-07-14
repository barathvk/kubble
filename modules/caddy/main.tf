resource "docker_image" "caddy" {
  name = "caddy:latest"
}
resource "docker_container" "caddy" {
  depends_on = [null_resource.certs]
  image = docker_image.caddy.latest
  name  = "caddy"
  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 2018
    external = 2018
  }
  ports {
    internal = 2019
    external = 2019
  }
  volumes {
    container_path = "/etc/caddy/Caddyfile"
    host_path      = abspath("${path.root}/Caddyfile")
    read_only      = true
  }
  volumes {
    container_path = "/root/.caddy"
    host_path      = abspath("${path.root}/certs")
    read_only      = true
  }
  volumes {
    container_path = "/root/html"
    host_path      = abspath("${path.root}/html")
    read_only      = true
  }
}