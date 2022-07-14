{{ range $ix, $cluster := .clusters }}
{{ $cluster }}.localhost {
  reverse_proxy http://host.docker.internal:{{ add $.base_port $ix 1 }}
  encode gzip
  tls /root/.caddy/tls.crt /root/.caddy/tls.key
  log {
    level INFO
  }
}
*.{{ $cluster }}.localhost {
  reverse_proxy http://host.docker.internal:{{ add $.base_port $ix 1 }}
  encode gzip
  tls /root/.caddy/tls.crt /root/.caddy/tls.key
  log {
    level INFO
  }
}
{{ end }}

:443 {
  root * /root/html
  file_server
  encode gzip
  tls /root/.caddy/tls.crt /root/.caddy/tls.key
  log {
    level INFO
  }
}