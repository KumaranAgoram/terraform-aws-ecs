# main.tf

# terraform import aws_vpc.aws-vpc <vpc_id>
resource "aws_vpc" "aws-vpc" {
  cidr_block = "10.11.12.0/24"
tags = {
    Name = "362255_Bayer_VPC"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = "10.11.12.0/26"

  tags = {
    Name = "362255_Bayer_Subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = "10.11.12.64/26"

  tags = {
    Name = "362255_Bayer_Subnet2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = "10.11.12.128/26"

  tags = {
    Name = "362255_Bayer_Subnet3"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id     = aws_vpc.aws-vpc.id
  cidr_block = "10.11.12.192/26"

  tags = {
    Name = "362255_Bayer_Subnet4"
  }
}

resource "aws_ecs_cluster" "cluster1" {
  name = "362255_Bayer_cluster" # Name your cluster here
  configuration {
    execute_command_configuration {
      logging    = "DEFAULT"
    }
  }
  service_connect_defaults {
  namespace = "arn:aws:servicediscovery:us-east-1:502433561161:namespace/ns-zjypygl4jodvifm7"
  }
}


resource "aws_ecs_task_definition" "task_def" {
  family                   = "362255_Bayer_Tsk2" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "362255_tomcat2",
      "image": "502433561161.dkr.ecr.us-east-1.amazonaws.com/362255_bayer_ecsrepo:build-eef37bdc-e6b2-4030-ba42-b4e8291c0d13",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 3072,
      "cpu": 1024
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 3072         # Specify the memory the container requires
  cpu                      = 1024         # Specify the CPU the container requires
  execution_role_arn       = "arn:aws:iam::502433561161:role/362255_Bayer_ECStaskexeutionrole"
}

resource "aws_ecs_service" "ecs-service" {
  name            = "362255_Bayer_ECSService2"
  cluster         = "${aws_ecs_cluster.cluster1.id}"
  task_definition = "${aws_ecs_task_definition.task_def.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups = ["sg-095e3a551fc5bcb2d"]
  }

}
