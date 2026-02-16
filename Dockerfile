# Etapa 1: Construcción
FROM node:18-alpine AS builder

# Variable para evitar descargar Chromium (reduce tamaño)
ENV PUPPETEER_SKIP_DOWNLOAD=true

# Instalar dependencias de compilación necesarias
RUN apk add --no-cache python3 make g++ git

# Instalar Flowise globalmente
RUN npm install -g flowise

# Etapa 2: Imagen final
FROM node:18-alpine

# Instalar SOLO dependencias runtime necesarias
RUN apk add --no-cache \
    chromium \
    git \
    python3 \
    make \
    g++ \
    cairo-dev \
    pango-dev \
    && rm -rf /var/cache/apk/*

# Configurar Puppeteer para usar Chromium del sistema
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copiar Flowise desde la etapa de construcción
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin /usr/local/bin

# --- SOLUCIÓN: Crear carpetas con permisos correctos ---
# Crear la estructura de directorios necesaria
RUN mkdir -p /root/.flowise/logs && \
    chmod -R 755 /root/.flowise

# Puerto por defecto
EXPOSE 3000

# Comando de inicio
CMD ["flowise", "start"]
