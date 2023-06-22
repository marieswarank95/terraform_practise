resource "aws_key_pair" "web_server_key" {
  key_name   = "web_server"
  public_key = file("web.pem.pub")
}