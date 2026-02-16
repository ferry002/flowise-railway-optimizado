# Usar Node.js 18 exacto (no alpine, no slim)
FROM node:18-bullseye

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Configurar Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

# Copiar package.json
COPY package.json .

# Limpiar cache de npm y forzar instalación limpia
RUN npm cache clean --force && \
    npm install --no-package-lock

# Crear directorios con permisos
RUN mkdir -p /root/.flowise/logs && \
    chmod -R 777 /root/.flowise

EXPOSE 3000

# Iniciar con opciones de Node.js para mayor compatibilidad
CMD ["node", "--max-old-space-size=2048", "/usr/local/bin/flowise", "start"]
