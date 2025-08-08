Zero-Cost Self-Healing Infrastructure Demo

🎯 The "Snowden Test" Scenario
Challenge: "You have 5 minutes to build a system that can detect a breach, destroy itself, and rebuild stronger. Go."

What it does:
-Simulates a web application running on EC2 (free tier)
-Detects "attack" via CloudWatch alarm (simulated high CPU/failed requests)
-Automatically terminates compromised instance
-Launches new instance from pre-configured AMI
-Updates load balancer to point to new instance
-Logs everything for forensic analysis
