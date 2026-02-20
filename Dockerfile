FROM node:20-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Instalar pnpm
RUN npm install -g pnpm@10.4.1

WORKDIR /app

# Copiar archivos del proyecto
COPY . .

# Si existe tar.gz, desempacar encima
RUN if [ -f manus-v2.6-SPEED.tar.gz ]; then \
      tar -xzf manus-v2.6-SPEED.tar.gz --strip-components=1 --overwrite && \
      rm -f manus-v2.6-SPEED.tar.gz; \
    fi

# Instalar dependencias
RUN pnpm install --frozen-lockfile 2>/dev/null || pnpm install

# Compilar el proyecto
RUN pnpm build

# Inicializar base de datos
RUN pnpm db:push 2>/dev/null || echo "DB will init on first run"

# Puerto
EXPOSE 3000

# Arrancar
CMD ["node", "dist/index.js"]
