# Usar Node.js 20 LTS
FROM node:20-slim

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Configurar Puppeteer para usar Chromium del sistema
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Crear directorio de trabajo
WORKDIR /app

# Copiar package.json primero (para cachear dependencias)
COPY package.json .

# Instalar dependencias
RUN npm install

# Copiar el resto (aunque solo tenemos package.json)
COPY . .

# Crear directorio de datos con permisos
RUN mkdir -p /root/.flowise/logs && \
    chmod -R 777 /root/.flowise

# Puerto
EXPOSE 3000

# Iniciar Flowise
CMD ["npm", "start"]
