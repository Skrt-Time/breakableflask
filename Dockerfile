# Image de base minimale et récente, version fixée
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Correctifs de sécurité de l'OS, sans garder le cache apt
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Utilisateur sans privilèges
RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

# Dépendances Python à jour
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --upgrade -r requirements.txt

# Uniquement le code utile
COPY main.py .

USER appuser

EXPOSE 4000

# Vérifie que l'app répond (sans installer curl)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:4000')" || exit 1

CMD ["python", "main.py"]
