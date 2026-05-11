import requests

url = "http://localhost:11434/api/generate"
model = "mistral"

contexto = []
MAX_HIST = 5  # limita histórico

print("Digite 'sair' para encerrar.\n")

while True:
    user_input = input("Você: ")

    if user_input.lower() == "sair":
        break

    contexto.append(f"Usuário: {user_input}")

    # mantém só últimas interações
    contexto = contexto[-MAX_HIST:]

    prompt = "\n".join(contexto) + "\nAssistente:"

    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }

    try:
        response = requests.post(url, json=payload, timeout=60)
        response.raise_for_status()

        data = response.json()

        resposta = data.get("response")

        if not resposta:
            print("⚠️ Resposta vazia do modelo\n")
            continue

        print(f"Assistente: {resposta}\n")

        contexto.append(f"Assistente: {resposta}")

    except requests.exceptions.RequestException as e:
        print(f"Erro na requisição: {e}\n")