## 👋 Welcome to ollama 🚀  

ollama README

This Docker container provides **Ollama** with a built-in **Open WebUI** for easy interaction with Large Language Models (LLMs).

**Features:**
- 🤖 Ollama server for running LLMs locally
- 🌐 Open WebUI - Full-featured web interface with authentication
- 📦 Auto-pull models on startup via MODELS environment variable
- 🐳 **Docker Model Runner (DMR) Compatible** - Works alongside Docker's built-in AI service
- ⚡ **CPU Optimized** - OpenBLAS for 3-5x faster CPU inference (8-12 tok/sec for 7B models)
- 🎮 **GPU Support** - NVIDIA (CUDA), AMD (ROCm), automatic detection and fallback
- 💻 **Smart Hardware Detection** - Automatically uses GPU if available, falls back to optimized CPU
- 💾 Persistent data storage for models and configurations
- 🔐 Automatic SSL/TLS support
- 📊 Health monitoring and logging
- 🏗️ Multi-architecture support (amd64, arm64)

**Ports:**
- `11434` - Ollama API server (DMR uses port 12434)
- `64080:80` - Open WebUI interface (host:container)

**Environment Variables:**

**Container/Models:**
- `MODELS` - Comma or space-separated list of models to auto-pull on startup
  - **Default**: If not set, automatically pulls `qwen2.5-coder:3b` (optimal for CPU coding)
  - Examples: 
    - `MODELS="llama3.2,mistral"`
    - `MODELS="llama3.2 mistral phi"`
    - `MODELS="llama3.2,mistral phi"` (mixed delimiters supported)
  - The first model in the list will be set as the default
  - Models are pulled from Ollama's registry (registry.ollama.ai)
  - **Note**: Docker Model Registry (DMR) is not yet natively supported by Ollama

**Ollama Configuration:**
- `OLLAMA_HOST` - IP address and port for Ollama (default: `0.0.0.0:11434`)
- `OLLAMA_MODELS` - Path to models directory (default: `/data/ollama/models`)
- `OLLAMA_KEEP_ALIVE` - Duration models stay loaded in memory (default: `5m`)
- `OLLAMA_MAX_LOADED_MODELS` - Maximum loaded models per GPU (default: `0` = unlimited)
- `OLLAMA_NUM_PARALLEL` - Maximum parallel requests (default: `1`)
- `OLLAMA_MAX_QUEUE` - Maximum queued requests (default: `512`)
- `OLLAMA_CONTEXT_LENGTH` - Default context length (default: `4096`)
- `OLLAMA_DEBUG` - Enable debug logging (set to `1` to enable)
- `OLLAMA_ORIGINS` - Allowed CORS origins (default: `*`)
- `OLLAMA_FLASH_ATTENTION` - Enable flash attention (set to `1`)
- `OLLAMA_GPU_OVERHEAD` - Reserve VRAM per GPU in bytes

**Open WebUI Configuration:**
- `WEBUI_URL` - URL where Open WebUI is accessible (default: `http://localhost:64080`)
- `WEBUI_NAME` - Custom name for the WebUI (default: `Open WebUI`)
- `WEBUI_SECRET_KEY` - Secret key for sessions (auto-generated if not set)
- `ENABLE_SIGNUP` - Allow new user registrations (default: `true`)
- `DEFAULT_USER_ROLE` - Role for new users: `pending`, `user`, or `admin` (default: `pending`)
- `DEFAULT_MODELS` - Comma-separated default model IDs
- `OLLAMA_BASE_URL` - Ollama API URL (default: `http://127.0.0.1:11434`)
- `ENABLE_ADMIN_EXPORT` - Allow admins to export data (default: `true`)

**GPU-Specific:**
- `CUDA_VISIBLE_DEVICES` - Which NVIDIA GPUs to use
- `HIP_VISIBLE_DEVICES` - Which AMD GPUs to use (numeric ID)
- `ROCR_VISIBLE_DEVICES` - Which AMD GPUs to use (UUID or ID)
- `HSA_OVERRIDE_GFX_VERSION` - Override AMD GPU GFX version

**CPU Optimization:**
- `OLLAMA_NUM_THREADS` - CPU cores for inference (default: auto-detect, uses all cores)
- `OPENBLAS_NUM_THREADS` - Override OpenBLAS threads (default: matches OLLAMA_NUM_THREADS)
- `OMP_NUM_THREADS` - Override OpenMP threads (default: matches OLLAMA_NUM_THREADS)

**Performance Tuning:**
Recommended settings for different hardware:

**CPU-only (4-core/16GB):**
```bash
-e OLLAMA_NUM_PARALLEL=2 \
-e OLLAMA_MAX_LOADED_MODELS=1 \
-e MODELS="qwen2.5-coder:3b"  # Expected: 10-20 tok/sec
```

**CPU-only (8-core/32GB):**
```bash
-e OLLAMA_NUM_PARALLEL=4 \
-e OLLAMA_MAX_LOADED_MODELS=1 \
-e MODELS="qwen2.5:7b"  # Expected: 8-12 tok/sec with OpenBLAS
```

**GPU (any size):**
```bash
--gpus all \
-e OLLAMA_NUM_PARALLEL=4 \
-e OLLAMA_MAX_LOADED_MODELS=0 \
-e MODELS="llama3.2:70b"  # Expected: 50-150+ tok/sec
```

**Hardware Acceleration:**

This container includes **automatic hardware detection** and optimization:

**✅ CPU Optimizations (Built-in):**
- **OpenBLAS**: Optimized BLAS library for 3-5x faster matrix operations
- **Multi-threading**: Automatically configures for available CPU cores
- **Expected Performance**:
  - 7B models (qwen2.5:7b): 8-12 tokens/sec on 8-core CPU
  - 3B models (qwen2.5-coder:3b): 10-20 tokens/sec on 4-core CPU
  - 1.5B models: 20-40 tokens/sec on 4-core CPU

**🎮 GPU Support (Automatic Detection):**
- **NVIDIA GPUs**: ✅ Full CUDA support (production ready)
  - Performance: 50-150+ tokens/sec (7B models)
  - Requirement: nvidia-container-toolkit on host
  - Flag: `--gpus all`
  
- **AMD GPUs**: ✅ Full ROCm support (production ready)
  - Performance: 40-120+ tokens/sec (7B models)
  - Requirement: ROCm 5.x+ drivers on host
  - Flags: `--device=/dev/kfd --device=/dev/dri`

- **Intel GPUs**: ⚠️ Experimental/Limited support
  - Performance: Variable (10-60 tokens/sec, often slower than CPU)
  - Works: Arc GPUs (experimental), iGPUs (limited)
  - Flag: `--device=/dev/dri`
  - Note: CPU mode often faster for integrated GPUs

- **Automatic Fallback**: Uses optimized CPU when no GPU detected

**Container automatically:**
- ✅ Detects available GPU at startup
- ✅ Uses GPU if available (100+ tok/sec for 7B models)
- ✅ Falls back to optimized CPU if no GPU (8-12 tok/sec for 7B models)
- ✅ Configures threads based on available CPU cores
- ✅ Sets optimal BLAS library parameters

**To enable GPU access:**

```bash
# NVIDIA GPU (requires nvidia-container-toolkit on host)
# ✅ RECOMMENDED - Best performance
docker run -d --gpus all -p 11434:11434 -p 64080:80 casjaysdevdocker/ollama

# AMD GPU (requires ROCm 5.x+ drivers)
# ✅ RECOMMENDED - Good performance
docker run -d --device=/dev/kfd --device=/dev/dri -p 11434:11434 -p 64080:80 casjaysdevdocker/ollama

# Intel GPU (Arc or integrated)
# ⚠️ EXPERIMENTAL - May not work, CPU often faster
docker run -d --device=/dev/dri -p 11434:11434 -p 64080:80 casjaysdevdocker/ollama

# CPU-only (no flags needed - automatically optimized)
# ✅ RECOMMENDED - Reliable 8-12 tok/sec with OpenBLAS
docker run -d -p 11434:11434 -p 64080:80 casjaysdevdocker/ollama
```

**GPU Performance Expectations:**
- **NVIDIA**: 50-150+ tok/sec (7B), 30-60 tok/sec (13B), 10-30 tok/sec (70B)
- **AMD**: 40-120+ tok/sec (7B), 25-50 tok/sec (13B), 8-25 tok/sec (70B)
- **Intel**: 10-60 tok/sec (highly variable, experimental)
- **CPU (Optimized)**: 8-12 tok/sec (7B), 5-8 tok/sec (13B)

**Note**: No GPU drivers/libraries are installed in the container. GPU access works via runtime device passthrough from the host system. This keeps the image lightweight (10.2GB) while supporting NVIDIA and AMD GPUs. Intel GPU support is experimental and not officially supported by Ollama.  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update ollama
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/ollama/rootfs"
git clone "https://github.com/dockermgr/ollama" "$HOME/.local/share/CasjaysDev/dockermgr/ollama"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/ollama/rootfs/." "$dockerHome/"

# Simple start - uses default model (qwen2.5-coder:3b, optimal for CPU)
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-ollama-latest \
--hostname ollama \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 11434:11434 \
-p 64080:80 \
casjaysdevdocker/ollama:latest

# For CPU-only with custom models
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-ollama-latest \
--hostname ollama \
-e TZ=${TIMEZONE:-America/New_York} \
-e MODELS="llama3.2,mistral" \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 11434:11434 \
-p 64080:80 \
casjaysdevdocker/ollama:latest

# For NVIDIA GPU with auto-pull models
docker run -d \
--restart always \
--privileged \
--gpus all \
--name casjaysdevdocker-ollama-latest \
--hostname ollama \
-e TZ=${TIMEZONE:-America/New_York} \
-e MODELS="llama3.2 mistral phi" \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 11434:11434 \
-p 64080:80 \
casjaysdevdocker/ollama:latest

# For AMD GPU
docker run -d \
--restart always \
--privileged \
--device=/dev/kfd \
--device=/dev/dri \
--name casjaysdevdocker-ollama-latest \
--hostname ollama \
-e TZ=${TIMEZONE:-America/New_York} \
-e MODELS="llama3.2,mistral,phi" \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 11434:11434 \
-p 64080:80 \
casjaysdevdocker/ollama:latest
```

---

## 🔌 IDE & Client Integration

Once the container is running, you can connect various IDEs, editors, and applications to use Ollama's API.

### 📝 VSCode Extensions

#### **Continue.dev** - AI Code Assistant
1. Install the [Continue extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
2. Open VSCode Settings (Ctrl/Cmd+Shift+P → "Continue: Open config.json")
3. Add configuration:
```json
{
  "models": [
    {
      "title": "Ollama Llama3.2",
      "provider": "ollama",
      "model": "llama3.2",
      "apiBase": "http://localhost:11434"
    }
  ]
}
```

#### **Cody** - AI Code Assistant by Sourcegraph
1. Install [Cody extension](https://marketplace.visualstudio.com/items?itemName=sourcegraph.cody-ai)
2. Open Settings → Extensions → Cody
3. Configure:
```json
{
  "cody.experimental.ollamaModels": ["llama3.2", "mistral"],
  "cody.experimental.ollamaEndpoint": "http://localhost:11434"
}
```

#### **Ollama Autocoder**
1. Install [Ollama Autocoder](https://marketplace.visualstudio.com/items?itemName=Ollama.ollama-autocoder)
2. Settings → Extensions → Ollama Autocoder
3. Set API URL: `http://localhost:11434`

#### **Twinny** - AI Code Assistant
1. Install [Twinny extension](https://marketplace.visualstudio.com/items?itemName=rjmacarthy.twinny)
2. Configure in settings:
```json
{
  "twinny.ollamaApiUrl": "http://localhost:11434",
  "twinny.ollamaModel": "llama3.2"
}
```

---

### 🖥️ IDE Applications

#### **Cursor** - AI-First Code Editor
1. Open Cursor → Settings → Models
2. Select "OpenAI Compatible"
3. Configure:
   - **Base URL**: `http://localhost:11434/v1`
   - **API Key**: `ollama` (or leave empty)
   - **Model**: `llama3.2`

#### **Claude Code / Windsurf**
1. Open Settings → AI Provider
2. Select "Custom OpenAI Compatible"
3. Configure:
   - **Endpoint**: `http://localhost:11434/v1/chat/completions`
   - **Model**: `llama3.2`
   - **API Key**: Not required

#### **JetBrains IDEs** (IntelliJ, PyCharm, etc.)
1. Install [Ollama plugin](https://plugins.jetbrains.com/plugin/22433-ollama)
2. Settings → Tools → Ollama
3. Set Server URL: `http://localhost:11434`

---

### 🌐 Desktop Applications

#### **Open WebUI** (Built-in)
- **URL**: `http://localhost:64080`
- Full-featured web interface with authentication
- Supports chat, model management, RAG, and more

#### **Ollama Desktop Client**
- Connect to: `http://localhost:11434`
- Native desktop experience for model management

#### **Jan** - ChatGPT Alternative
1. Download [Jan](https://jan.ai/)
2. Settings → Advanced → OpenAI Compatible
3. Set Base URL: `http://localhost:11434/v1`

#### **Enchanted** (macOS/iOS)
1. Download from App Store
2. Settings → Ollama Server
3. Set URL: `http://localhost:11434`

---

### 🔧 API Integration

#### **OpenAI-Compatible Endpoints**
Ollama provides OpenAI-compatible API endpoints:

```bash
# Chat Completions (OpenAI compatible)
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Completions
curl http://localhost:11434/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2",
    "prompt": "Tell me a joke"
  }'

# List Models
curl http://localhost:11434/v1/models
```

#### **Native Ollama API**
```bash
# Generate
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Why is the sky blue?",
  "stream": false
}'

# Chat
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hello!"}],
  "stream": false
}'

# List Models
curl http://localhost:11434/api/tags
```

---

### 🐍 Python Integration

```python
# Using OpenAI Python SDK
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # Not required but SDK needs something
)

response = client.chat.completions.create(
    model="llama3.2",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

```python
# Using Ollama Python Library
import ollama

response = ollama.chat(
    model='llama3.2',
    messages=[{'role': 'user', 'content': 'Hello!'}]
)
print(response['message']['content'])
```

---

### 🦀 Rust Integration

```toml
# Cargo.toml
[dependencies]
ollama-rs = "0.2"
```

```rust
use ollama_rs::Ollama;

#[tokio::main]
async fn main() {
    let ollama = Ollama::new("http://localhost".to_string(), 11434);
    
    let response = ollama.generate("llama3.2", "Why is the sky blue?").await;
    println!("{}", response.unwrap());
}
```

---

### 🟦 JavaScript/TypeScript Integration

```bash
npm install ollama
```

```javascript
import { Ollama } from 'ollama'

const ollama = new Ollama({ host: 'http://localhost:11434' })

const response = await ollama.chat({
  model: 'llama3.2',
  messages: [{ role: 'user', content: 'Hello!' }],
})

console.log(response.message.content)
```

---

### 🔐 CORS Configuration

The container is configured with `OLLAMA_ORIGINS="*"` by default, allowing all origins. To restrict access:

```bash
docker run -d \
  -e OLLAMA_ORIGINS="http://localhost:3000,https://myapp.com" \
  -p 11434:11434 -p 64080:80 \
  casjaysdevdocker/ollama:latest
```

---

### 🚀 Quick Test

Verify the API is working:

```bash
# Check version
curl http://localhost:11434/api/version

# Test chat (requires a model pulled first)
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Hello"}],
  "stream": false
}'
```

---

## 📦 Docker Model Runner (DMR) Integration

### ✅ Compatible with Docker Model Runner

Docker Model Runner is Docker's built-in AI service that runs models directly within Docker Desktop/Engine. It provides **Ollama-compatible APIs** on port **12434**.

**This container (port 11434) and DMR (port 12434) can work side-by-side:**

```bash
# DMR runs on port 12434 (Docker's built-in)
curl http://localhost:12434/api/tags

# This Ollama container runs on port 11434
curl http://localhost:11434/api/tags
```

### When to Use Each

| Feature | This Container (Ollama) | Docker Model Runner (DMR) |
|---------|------------------------|---------------------------|
| **Port** | 11434 | 12434 |
| **Built-in WebUI** | ✅ Open WebUI on 64080 | ❌ (use external tools) |
| **Auto-pull models** | ✅ Via MODELS env var | ✅ Via docker model pull |
| **Model storage** | /data/ollama/models | Docker-managed |
| **GPU support** | ✅ NVIDIA/AMD/Intel | ✅ NVIDIA (vLLM/Diffusers) |
| **Inference engines** | Ollama default | llama.cpp, vLLM, Diffusers |
| **Requires** | Docker container | Docker Desktop 4.40+ |
| **API compatibility** | Ollama, OpenAI (v1) | Ollama, OpenAI, Anthropic |

### Using Both Together

**Scenario 1: DMR for quick testing, Container for production**
```bash
# Quick test with DMR (no container needed)
docker model pull ai/llama3.2
curl http://localhost:12434/api/chat -d '{...}'

# Production with full WebUI and auto-pull
docker run -d -e MODELS="llama3.2" -p 11434:11434 -p 64080:80 casjaysdevdocker/ollama
```

**Scenario 2: IDE points to container, DMR for experiments**
```json
// VSCode Continue extension → this container
{
  "models": [{
    "apiBase": "http://localhost:11434"
  }]
}
```

**Scenario 3: Open WebUI connects to DMR instead**
```bash
# Run this container but point WebUI to DMR
docker run -d \
  -e OLLAMA_BASE_URL="http://172.17.0.1:12434" \
  -p 64080:80 \
  casjaysdevdocker/ollama
```

### Docker Model Runner Commands

```bash
# Enable DMR in Docker Desktop
docker desktop enable model-runner --tcp 12434

# Pull models via DMR
docker model pull ai/llama3.2
docker model pull ai/mistral

# List DMR models
docker model ls

# Chat with DMR (Ollama-compatible API)
curl http://localhost:12434/api/chat -d '{
  "model": "ai/llama3.2",
  "messages": [{"role": "user", "content": "Hello"}]
}'

# Use OpenAI-compatible endpoint
curl http://localhost:12434/engines/v1/chat/completions -d '{
  "model": "ai/llama3.2",
  "messages": [{"role": "user", "content": "Hello"}]
}'
```

### IDE Configuration for DMR

**Continue.dev with DMR:**
```json
{
  "models": [{
    "title": "DMR Llama3.2",
    "provider": "ollama",
    "model": "ai/llama3.2",
    "apiBase": "http://localhost:12434"
  }]
}
```

**Cursor with DMR:**
- Base URL: `http://localhost:12434/engines/v1`
- Model: `ai/llama3.2`

### Model Registry Differences

**Ollama Registry (This Container):**
- Models from: `registry.ollama.ai`
- Format: `llama3.2`, `mistral`, `phi`
- Pull via: `ollama pull` or MODELS env var

**Docker Model Runner (DMR):**
- Models from: Docker Hub (`hub.docker.com/u/ai`)
- Format: `ai/llama3.2`, `ai/mistral`, `ai/qwen2.5-coder`
- Pull via: `docker model pull`
- Supports OCI artifacts

### Benefits of Using Both

1. **DMR**: Quick model testing without container overhead
2. **This Container**: Full-featured deployment with WebUI, authentication, auto-pull
3. **Flexibility**: Switch between them via port configuration
4. **Integration**: Use DMR for CI/CD, container for production apps

### Requirements

**Docker Model Runner:**
- Docker Desktop 4.40+ (macOS) or 4.41+ (Windows)
- Docker Engine with DMR plugin
- Enable via: Settings → Features → Enable Docker Model Runner

**This Container:**
- Standard Docker (no version requirements)
- Works anywhere Docker runs

---
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ollama:
    image: casjaysdevdocker/ollama
    container_name: casjaysdevdocker-ollama
    environment:
      - TZ=America/New_York
      - HOSTNAME=ollama
      - MODELS=llama3.2,mistral,phi
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/ollama/ollama/latest/rootfs/config:/config:z"
    ports:
      - 11434:11434
      - 64080:80
    restart: always
    # For NVIDIA GPU, uncomment:
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: all
    #           capabilities: [gpu]
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/ollama
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/ollama" "$HOME/Projects/github/casjaysdevdocker/ollama"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/ollama"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
