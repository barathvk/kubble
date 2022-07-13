variable "clusters" {
  type = list(object({name = string, port = number}))
}