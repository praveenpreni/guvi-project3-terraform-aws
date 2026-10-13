#!/bin/bash
set -euo pipefail
# The EIP is associated after instance creation; retry until internet is available.
for attempt in $(seq 1 60); do
  if dnf install -y nginx; then break; fi
  sleep 10
done
rpm -q nginx
cat > /usr/share/nginx/html/index.html <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>GUVI Project 3 | Terraform on AWS</title>
<style>body{margin:0;background:#0b1220;color:#e6edf7;font:18px system-ui}main{max-width:850px;margin:12vh auto;padding:35px}small{color:#62e3bc}h1{font-size:clamp(36px,6vw,64px)}p{line-height:1.7;color:#b6c5dd}.cards{display:flex;flex-wrap:wrap;gap:14px}.cards span{padding:18px;background:#18263c;border-radius:12px}</style></head>
<body><main><small>GUVI DEVOPS • PROJECT 03</small><h1>Infrastructure as code.<br>Deployed with confidence.</h1>
<p>AWS infrastructure provisioned with reusable Terraform modules and deployed through GitHub Actions with a reviewed plan and manual approval.</p>
<div class="cards"><span>Terraform</span><span>GitHub Actions</span><span>Amazon EC2 + Nginx</span><span>Secure Amazon S3</span></div>
<p id="health">Project 3 deployment successful</p></main></body></html>
HTML
systemctl enable --now nginx
curl --fail http://localhost/ | grep -q 'Project 3 deployment successful'
