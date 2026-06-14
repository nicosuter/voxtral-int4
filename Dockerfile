FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Install uv and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 libsndfile1 curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -s /root/.local/bin/uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency file first for layer caching
COPY pyproject.toml /app/pyproject.toml

# Install deps with uv (layer cached unless pyproject.toml changes)
RUN uv pip install --system --no-cache-dir \
    torch==2.6.* --index-url https://download.pytorch.org/whl/cu124 \
    && uv pip install --system --no-cache-dir -r pyproject.toml

COPY src/ /app/src/

WORKDIR /app/src
EXPOSE 8080

ENTRYPOINT ["python3", "serve.py"]
