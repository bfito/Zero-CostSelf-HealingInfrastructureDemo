# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for Phoenix target
resource "aws_security_group" "phoenix_sg" {
  name_prefix = "${var.project_name}-sg"
  description = "Security group for Phoenix Defense demo"

  ingress {
    from_port = 80
    to_port= 80
    protocol= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port= 22
    protocol= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port=0
    protocol= "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-security-group"
  }
}

# The target instance
resource "aws_instance" "phoenix_target" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.phoenix_sg.id]

  user_data = base64encode(templatefile("${path.module}/../configs/user-data.sh", {
    project_name = var.project_name
}))

  tags = {
    Name = "${var.project_name}-target"
    Purpose = "phoenix-demo-target"
  }
}

# CloudWatch Alarm - This triggers the Phoenix protocol
resource "aws_cloudwatch_metric_alarm" "phoenix_breach_alarm" {
  alarm_name = "${var.project_name}-breach-detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name= "CPUUtilization"
  namespace= "AWS/EC2"
  period= "60"
  statistic= "Average"
  threshold = var.alarm_threshold
  alarm_description = "This alarm monitors CPU utilization for Phoenix demo"

  dimensions = {
    InstanceId = aws_instance.phoenix_target.id
  }

  alarm_actions = [aws_lambda_function.phoenix_response.arn]

  tags = {
    Name = "${var.project_name}-alarm"
  }
}