# Task 2

## Create the same thing (vpc, and instances) in a different region, make sure the IP addresses do not overlap, create a vpc peering connection between the two VPC's, ping the private instance in region b from the private instance in region a. *This means that you have to ssh into the private instances in both regions

### 1. Create a VPC in Frankfurt Region

Another VPC was created in the Frankfurt Region with the following details:

* Name: `world-war-2`
* IPv4 CIDR block: `10.1.0.0/24`

![Create a VPC](./frankfurt-region/frankfurt%20vpc.png)

### 2. Create a public subnet in Frankfurt Region

Another public subnet was created in the Frankfurt Region with the following details:

* Name: `blitzkrieg-public`
* VPC: `world-war-2`
* IPv4 CIDR block: `10.1.0.0/28`

![Create a public subnet](./frankfurt-region/frankfurt%20public%20subnet.png)

### 3. Create a private subnet in Frankfurt Region

Another private subnet was created in the Frankfurt Region with the following details:

* Name: `blitzkrieg-private`
* VPC: `world-war-2`
* IPv4 CIDR block: `10.1.0.16/28`

![Create a private subnet](./frankfurt-region/frankfurt%20private%20subnet.png)

### 4. Create a Internet Gateway in Frankfurt Region

Another Internet Gateway was created in the Frankfurt Region to route the instances in the public subnet to the internet with the following details:

* Name: `general-Goering-igw`
* VPC: `world-war-2`

![Create a Internet Gateway](./frankfurt-region/frankfurt%20igw.png)

### 5. Create a Public Route Table in Frankfurt Region

Another Public Route Table was created in the Frankfurt Region to route the public subnet to the internet gateway with the following details:

* Name: `general-Goering-pub`
* Subnet: `blitzkrieg-public`

![Create a Public Route Table](./frankfurt-region/public%20route%20table%20frankfurt.png)

### 6a. Create a Private Route Table in Frankfurt Region

Another Private Route Table was created in the Frankfurt Region to route the private subnet to the NAT gateway, however the NAT gateway was not created, it had the following details:

* Name: `general-Goering-priv`
* Subnet: `blitzkrieg-private`

![Create a Private Route Table](./frankfurt-region/private%20route%20table%20frankfurt.png)

### 6b. private instance could not connect with the internet due to lack of NAT gateway

![Private instance could not connect with the internet](./frankfurt-region/require%20nat%20gateway.png)

### 7. Create a key pair to use for the EC2 instances in Frankfurt Region

![Create a key pair](./frankfurt-region/frankfurt%20keypair.png)

### 8. Create a Public Security Group in Frankfurt Region

Another Public Security Group was created in the Frankfurt Region with the following details:

* Name: `luftwaffe-pub`
* VPC: `world-war-2`
* Description: `Allow SSH access from my IP address`

![Create a Public Security Group](./frankfurt-region/public%20secur%20grp%20frankfurt.png)

### 9a. Create a Private Security Group in Frankfurt Region

Another Private Security Group was created in the Frankfurt Region with the following details:

* Name: `luftwaffe-priv`
* VPC: `world-war-2`
* Description: `Allow SSH and ICMP traffics from public security group`

![Create a Private Security Group](./frankfurt-region/priv%20security%20group.png)

### 9b. due to the ICMP rule in the private security group, i could ping the private instance from public instance

![Ping the private instance from public instance](./frankfurt-region/successful%20ping.png)

### 10a. Create a public instance in Frankfurt Region

A public instance was created in the Frankfurt Region with the following details:

* Name: `nazi-pub-instance`
* VPC: `world-war-2`
* Subnet: `blitzkrieg-public`
* Auto-assign Public IP: `Enable`
* Key pair: `JARVIS-B`
* Security Group: `luftwaffe-pub`

![Create a public instance](./frankfurt-region/public%20instance%20in%20frankfurt.png)

### 10b. SSH into the public instance from local machine

![SSH into the public instance from local machine](./frankfurt-region/successfulssh%20into%20public%20instance.png)

### 11. Create a private instance in Frankfurt Region

A private instance was created in the Frankfurt Region with the following details:

* Name: `nazi-priv-instance`
* VPC: `world-war-2`
* Subnet: `blitzkrieg-private`
* Auto-assign Public IP: `Disable`
* Key pair: `JARVIS-B`
* Security Group: `luftwaffe-priv`

![Create a private instance](./frankfurt-region/private%20instance%20frankfurt.png)

### 12. SSH into the private instance from the public instance

![copied private key from local machiine to public instance to enble ssh into private instance](./frankfurt-region/scp%20keypair.png)

![SSH into the private instance from the public instance](./frankfurt-region/ssh%20from%20pub%20to%20priv%20in%20frankfurt.png)

### 13. Create a VPC Peering Connection between the VPCs in Stockholm and Frankfurt Regions

A VPC Peering Connection was created between the VPCs in Stockholm and Frankfurt Regions with the following details:

* Name: `winston-churchill`
* VPC (Requester): `david-jones-locker`
* VPC (Accepter): `world-war-2`

![Create a VPC Peering Connection](./peering%20connection/peering%20connection.png)

### 14. Accept the VPC Peering Connection in the Frankfurt Region

![Accept the VPC Peering Connection](./peering%20connection/frankfurt%20peering%20connect.png)

### 15. Add a route to the private route table in the Stockholm Region

A route was added to the private route table in the Stockholm Region with the following details:

* Destination: `10.0.0.0/24`

![Add a route to the private route table](./peering%20connection/frankfurt%20rout%20table%20edit.png)

### 16. Add a route to the private route table in the Frankfurt Region

A route was added to the private route table in the Frankfurt Region with the following details:

* Destination: `10.1.0.0./24`

![Add a route to the private route table](./peering%20connection/stockholm%20route%20table%20edit.png)

### 17. Security Group rules were added to the private security group in the Stockholm Region

The private security group in the Stockholm Region was edited with the following details:

* Type: `All ICMP - IPv4`
* Protocol: `ICMP`
* Port Range: `ALL`
* Source: `10.1.0.0/24`

![Security Group rules were added to the private security group](./peering%20connection/stockholm%20privatesecurity%20group%20update.png)

### 18. Security Group rules were added to the private security group in the Frankfurt Region

The private security group in the Frankfurt Region was edited with the following details:

* Type: `All ICMP - IPv4`
* Protocol: `ICMP`
* Port Range: `ALL`
* Source: `10.0.0.0/24`

![Security Group rules were added to the private security group](./peering%20connection/frankfurt%20private%20security%20group%20update.png)

### 19. Ping the private instance in the Frankfurt Region from the private instance in the Stockholm Region

![Ping the private instance in the Stockholm Region from the private instance in the Frankfurt Region](./peering%20connection/successful%20inter%20region%20ping.png)

## THE END
