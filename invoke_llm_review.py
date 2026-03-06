import os
import requests
import json

# 1. Initialize environment variables
azure_oai_key = os.environ.get("AZURE_OPENAI_KEY")
azure_oai_endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")
github_token = os.environ.get("GITHUB_TOKEN")
pr_number = os.environ.get("PR_NUMBER")
repo_name = os.environ.get("GITHUB_REPOSITORY")

# 2. Ingest Terraform configuration
with open("main.tf", "r") as file:
    infrastructure_code = file.read()

# 3. Request architectural review from Azure OpenAI
headers = {
    "Content-Type": "application/json",
    "api-key": azure_oai_key
}

system_prompt = "You are a Senior Cloud Architect. Review this Terraform configuration for security vulnerabilities and compliance issues. Provide the corrected HCL code and a brief explanation."
user_prompt = f"Review this code:\n\n{infrastructure_code}"

payload = {
    "messages": [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt}
    ],
    "temperature": 0.1
}


api_url = f"{azure_oai_endpoint}/openai/deployments/ai-secure-lab001/chat/completions?api-version=2023-05-15"

response = requests.post(api_url, headers=headers, json=payload)
response_data = response.json()
remediation_plan = response_data["choices"][0]["message"]["content"]

# 4. Publish remediation plan to GitHub Pull Request
gh_api_url = f"https://api.github.com/repos/{repo_name}/issues/{pr_number}/comments"
gh_headers = {
    "Authorization": f"Bearer {github_token}",
    "Accept": "application/vnd.github.v3+json"
}
gh_payload = {
    "body": f"### 🛡️ Architectural Security Review\n\n**Automated Analysis:**\n{remediation_plan}"
}

requests.post(gh_api_url, headers=gh_headers, json=gh_payload)