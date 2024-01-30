variable "do_token" {}
variable "ssh_fingerprint" {}
variable "calebluka_priv_key" {}

terraform{
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~> 2.0"
        }
    }
}

# cofigure the digitalocean provider
provider "digitalocean" {

}



# create a web server 
resource "digitalocean_droplet" "web1" {
    ssh_keys = [
        var.ssh_fingerprint
    ]
   image               = "ubuntu-20-04-x64"
   region              = "lon1"
   size                = "s-1vcpu-1gb"
   backups             = "true"
   name                = "web1"
   monitoring = true

   connection {
        host = self.ipv4_address
        type      = "ssh"
        user      = "root"
        private_key = file(var.calebluka_priv_key)
    }
   provisioner "remote_exec" {
    
    inline = [
        "apt update",
        "apt install -y apache2",
        "echo '<h1>Welcome to Altschool - 1</h1>' > /var/www/html/index.html"
    ]
   }
}

output "web_01_ip" {
    value = "${digitalocean_droplet.web1.ipv4_address}"
}

output "web_01_ip_private" {
    value = "${digitalocean_droplet.web1.ipv4_address_private}"
}

output "web_01_cost" {
    value = "${digitalocean_droplet.web1.price_monthly}"
}

# create a web server 
resource "digitalocean_droplet" "web2" {
    ssh_keys = [
        var.ssh_fingerprint
    ]
   image               = "ubuntu-20-04-x64"
   region              = "lon1"
   size                = "s-1vcpu-1gb"
   backups             = "true"
   name                = "web1"
   monitoring = true
   connection {
        host = self.ipv4_address
        type      = "ssh"
        user      = "root"
        private_key = file(var.calebluka_priv_key)
    }
   provisioner "remote_exec" {
    
    inline = [
        "apt update",
        "apt install -y apache2",
        "echo '<h1>Welcome to Altschool - 2</h1>' > /var/www/html/index.html"
    ]
   }
}

output "web_02_ip" {
    value = "${digitalocean_droplet.web2.ipv4_address}"
}

output "web_02_ip_private" {
    value = "${digitalocean_droplet.web2.ipv4_address_private}"
}

output "web_02_cost" {
    value = "${digitalocean_droplet.web2.price_monthly}"
}


resource "digitalocean_loadbalancer" "publiclb" {
    name = "publiclb"
    region = "lon1"

    forwarding_rule { 
        entry_port     =80  
        entry_protocol = "http"

        target_port     = 80
        target_protocol = "http"
    } 
    
    healthcheck {
        port = 22
        protocol = "tcp"

    }
    droplet_ids = ["${digitalocean_droplet.web1.id}", "${digitalocean_droplet.web2.id}"]
}

output "lb_id" {
    value = "${digitalocean_loadbalancer.publiclb.ip}"
}
