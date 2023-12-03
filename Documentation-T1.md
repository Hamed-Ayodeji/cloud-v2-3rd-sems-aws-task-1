# Task 1

## Create a VPC with public and private subnets, and launch two instances(free-tier), one in the public subnet and another in the private subnet, you must be able to ping the private instance from the public instance through the private IP address of the private instance

### 1. Create a VPC in Stockholm Region

A VPC was created in the Stockholm Region with the following details:

* Name: `david-jones-locker`
* IPv4 CIDR block: `10.0.0.0/24`

![Create a VPC](./stockholm-region/vpc%20creation%20in%20stockholm.png)

### 2. Create a public subnet in Stockholm Region

A public subnet was created in the Stockholm Region with the following details:

* Name: `black-beard-pub`
* VPC: `david-jones-locker`
* IPv4 CIDR block: `10.0.0.0/28`

![Create a public subnet](./stockholm-region/publicSubnet%20creation%20.png)

### 3. Create a private subnet in Stockholm Region

A private subnet was created in the Stockholm Region with the following details:

* Name: `black-beard-priv`
* VPC: `david-jones-locker`
* IPv4 CIDR block: `10.0.0.16/28`

![Create a private subnet](./stockholm-region/Private%20Subnet%20creation.png)

### 4. Create a Internet Gateway in Stockholm Region

An Internet Gateway was created in the Stockholm Region to route the instances in the private subnet to the internet with the following details:

* Name: `fountain-of-youth-igw`
* VPC: `david-jones-locker`

![Create a Internet Gateway](./stockholm-region/internet%20gateway%20creation.png)

### 5. Create a Public Route Table in Stockholm Region

A Public Route Table was created in the Stockholm Region to route the public subnet to the internet gateway with the following details:

* Name: `stranger-tide-pub`

![Create a Public Route Table](./stockholm-region/Public%20Route%20table.png)

### 6. Create a Private Route Table in Stockholm Region

A Private Route Table was created in the Stockholm Region to route the private subnet to the NAT gateway, however the NAT gateway was not created, it had the following details:

* Name: `stranger-tide-priv`

![Create a Private Route Table](./stockholm-region/Private%20routetable%20.png)

### 7. Create a key pair to use for the EC2 instances in Stockholm Region

![Create a key pair](./stockholm-region/Key%20pair%20for%20stock%20holm.png)

### 8. Create a Public Security Group in Stockholm Region

A public security group was created for the public instance in the Stockholm Region with the following details:

* Name: `dying-gull-pub-secure`
* Description: `Allow SSH only from my IP address`

![Create a Public Security Group](./stockholm-region/public%20security%20group.png)

### 9a. Create a Private Security Group in Stockholm Region

A private security group was created for the private instance in the Stockholm Region with the following details:

* Name: `dying-gull-priv-secure`
* Description: `Allow SSH and ICMP traffics only from the public security group`

![Create a Private Security Group](./stockholm-region/private%20security%20group.png)

### 9b. Due to the ssh rule set on the private security group, i could not ssh into the private instance from my local machine.

![Failed to ssh into the private instance from local machine](./stockholm-region/failed%20ssh%20connection%20from%20Local%20pc%20into%20private%20Instance.png)

### 9c. The ICMP rule set on the private security group, i can now ping the private instance from my public instance.

![Ping the private instance from public instance](./stockholm-region/Prove%20of%20the%20public%20instance%20Pinging%20the%20Private.png)

### 10. Create an EC2 instance in the public subnet in Stockholm Region

A public EC2 instance was created in the Stockholm Region with the following details:

* Name: `salazar-pub-instance`
* VPC: `david-jones-locker`
* Subnet: `black-beard-pub`
* Auto-assign Public IP: `Enable`
* Security Group: `dying-gull-pub-secure`
* Key pair: `JARVIS`

![Create an EC2 instance in the public subnet](./stockholm-region/stockholm%20pub%20instance.png)

### 11. Create an EC2 instance in the private subnet in Stockholm Region

A private EC2 instance was created in the Stockholm Region with the following details:

* Name: `salazar-priv-instance`
* VPC: `david-jones-locker`
* Subnet: `black-beard-priv`
* Auto-assign Public IP: `Disable`
* Security Group: `dying-gull-priv-secure`
* Key pair: `JARVIS`

![Create an EC2 instance in the private subnet](./stockholm-region/stockholm%20private%20instance.png)

### 12. SSH into the private instance from the public instance failed because of the absence of the private key on the public instance.

![SSH into the private instance from the public instance failed](./stockholm-region/ssh%20failed%20from%20pub%20to%20priv%20bcos%20of%20keypair%20absence%20in%20pub.png)

### 13. SSH into the private instance from the public instance succeeded after the private key was copied to the public instance.

![SSH into the private instance from the public instance succeeded](./stockholm-region/SCP%20keypair%20to%20pub%20instance.png)

![SSH into the private instance from the public instance succeeded](./stockholm-region/SSH%20into%20private%20instance.png)
