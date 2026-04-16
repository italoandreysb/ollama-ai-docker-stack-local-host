import requests

url = "http://localhost:11434/api/generate"

payload = {
    "model": "mistral",
    "prompt": "Olá, qual é a capital do Brasil?",
    "stream": False
}

response = requests.post(url, json=payload)

# Ver o JSON completo retornado
print(response.json())