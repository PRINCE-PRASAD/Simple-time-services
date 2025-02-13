# provider "aws" {
#   region = "us-east-1"  # Change as needed
# }

# # VPC
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "simple-time-service-vpc"
#   }
# }

# # Public Subnets
# resource "aws_subnet" "public_1" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   availability_zone = "us-east-1a"

#   tags = { Name = "public-subnet-1" }
# }

# resource "aws_subnet" "public_2" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"
#   map_public_ip_on_launch = true
#   availability_zone = "us-east-1b"

#   tags = { Name = "public-subnet-2" }
# }

# # Private Subnets
# resource "aws_subnet" "private_1" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.3.0/24"
#   availability_zone = "us-east-1a"

#   tags = { Name = "private-subnet-1" }
# }

# resource "aws_subnet" "private_2" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.4.0/24"
#   availability_zone = "us-east-1b"

#   tags = { Name = "private-subnet-2" }
# }

# # Internet Gateway for Public Subnets
# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.main.id

#   tags = { Name = "simple-time-service-igw" }
# }

# # Route Table for Public Subnets
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = { Name = "public-route-table" }
# }

# resource "aws_route_table_association" "public_assoc_1" {
#   subnet_id      = aws_subnet.public_1.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "public_assoc_2" {
#   subnet_id      = aws_subnet.public_2.id
#   route_table_id = aws_route_table.public_rt.id
# }

# # ECS Cluster
# resource "aws_ecs_cluster" "cluster" {
#   name = "simple-time-service-cluster"
# }

# # ECS Task Definition
# resource "aws_ecs_task_definition" "task" {
#   family                   = "simple-time-service-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"

#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   container_definitions = jsonencode([
#     {
#       name      = "simple-time-service"
#       image     = "princeprasad/simple-time-service:latest"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#         }
#       ]
#     }
#   ])
# }

# # ECS Service
# resource "aws_ecs_service" "service" {
#   name            = "simple-time-service"
#   cluster         = aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.task.arn
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
#     security_groups  = [aws_security_group.ecs_sg.id]
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#     container_name   = "simple-time-service"
#     container_port   = 3000
#   }

#   desired_count = 1
# }

# # Security Group for ECS
# resource "aws_security_group" "ecs_sg" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "ecs-security-group" }
# }

# # Load Balancer
# resource "aws_lb" "alb" {
#   name               = "simple-time-service-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ecs_sg.id]
#   subnets           = [aws_subnet.public_1.id, aws_subnet.public_2.id]

#   tags = { Name = "simple-time-service-alb" }
# }

# # Target Group
# resource "aws_lb_target_group" "ecs_tg" {
#   name        = "simple-time-service-tg"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"  # Change from "instance" to "ip"
# }

# # Listener
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#   }
# }

# # IAM Role for ECS Task Execution
# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = "ecsTaskExecutionRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
