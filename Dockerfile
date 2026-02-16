# Usar Node.js 18 LTS (no Alpine para evitar problemas de compatibilidad)
FROM node:18-bullseye

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

# --- SOLUCIÓN: Instalación explícita y verificación ---
# Instalar Flowise globalmente con más verbosidad
RUN npm install -g flowise@latest --verbose && \
    # Verificar que se instaló correctamente
    npm list -g --depth=0 && \
    # Crear enlace simbólico por si acaso
    ln -sf $(npm root -g)/flowise/bin/run.js /usr/local/bin/flowise 2>/dev/null || true

# Verificar que flowise está accesible
RUN which flowise || echo "⚠️ flowise no está en PATH, pero continuamos"

# Variables de entorno para Flowise
ENV DATABASE_PATH=/root/.flowise \
    APIKEY_PATH=/root/.flowise \
    SECRETKEY_PATH=/root/.flowise \
    LOG_PATH=/root/.flowise/logs \
    PORT=3000

# Crear directorios con permisos
RUN mkdir -p /root/.flowise/logs && \
    chmod -R 777 /root/.flowise

# Exponer puerto
EXPOSE 3000

# Comando de inicio mejorado: busca flowise en múltiples ubicaciones
CMD ["sh", "-c", " \
    if command -v flowise >/dev/null 2>&1; then \
        echo '✅ Flowise encontrado en PATH'; \
        flowise start --port=$PORT; \
    elif [ -f /usr/local/bin/flowise ]; then \
        echo '✅ Flowise encontrado en /usr/local/bin'; \
        /usr/local/bin/flowise start --port=$PORT; \
    elif [ -f $(npm root -g)/flowise/bin/run.js ]; then \
        echo '✅ Flowise encontrado en npm global'; \
        node $(npm root -g)/flowise/bin/run.js start --port=$PORT; \
    else \
        echo '❌ ERROR: No se encontró Flowise'; \
        npm list -g --depth=0; \
        exit 1; \
    fi \
    "]
