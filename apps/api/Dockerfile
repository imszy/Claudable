FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Keep repository-like paths so `app/core/config.py` project-root detection works
WORKDIR /workspace

# Install python deps first (better layer caching)
COPY apps/api/requirements.txt /workspace/apps/api/requirements.txt
RUN pip install --no-cache-dir -r /workspace/apps/api/requirements.txt

# Copy API source
COPY apps/api /workspace/apps/api

# Ensure default writable directories exist (ephemeral on FC, but fine for demos)
RUN mkdir -p /workspace/data /workspace/data/projects /workspace/data/repo

# Aliyun FC custom-container defaults to 9000; keep it consistent
ENV PORT=9000 \
    API_PORT=9000

WORKDIR /workspace/apps/api

EXPOSE 9000

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-9000} --log-level warning"]
