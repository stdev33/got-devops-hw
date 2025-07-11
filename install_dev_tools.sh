#!/bin/bash

# Exit the script immediately if any command exits with a non-zero status
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Checking and installing DevOps tools...${NC}"

# Check and install Docker
if ! command -v docker &> /dev/null; then
  echo -e "${GREEN}👉 Installing Docker...${NC}"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  echo -e "${GREEN}✅ Docker installed.${NC}"
else
  echo -e "${GREEN}✅ Docker is already installed.${NC}"
fi

# Check and install Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo -e "${GREEN}👉 Installing Docker Compose...${NC}"
  DOCKER_COMPOSE_VERSION="2.20.2"
  sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo -e "${GREEN}✅ Docker Compose installed.${NC}"
else
  echo -e "${GREEN}✅ Docker Compose is already installed.${NC}"
fi

# Check and install Python 3.9+
if command -v python3 &> /dev/null; then
  PYTHON_VERSION=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
  if python3 -c "import sys; exit(0) if sys.version_info >= (3,9) else exit(1)"; then
    echo -e "${GREEN}✅ Python $PYTHON_VERSION is already installed and satisfies version requirement (>= 3.9).${NC}"
  else
    echo -e "${GREEN}⚠️ Python version $PYTHON_VERSION is too old. Please upgrade manually to Python 3.9 or newer.${NC}"
  fi
else
  echo -e "${GREEN}👉 Installing Python 3...${NC}"
  sudo apt-get update
  sudo apt-get install -y python3
  echo -e "${GREEN}✅ Python 3 installed.${NC}"
fi

# Check and install pip
sudo apt-get update
sudo apt-get install -y python3-pip

if command -v pip3 &> /dev/null; then
  echo -e "${GREEN}✅ pip3 successfully installed.${NC}"
else
  echo -e "${RED}❌ Failed to install pip3.${NC}"
fi

# Check and install Django
echo -e "${GREEN}👉 Installing python3-venv if needed...${NC}"

# Get Python major.minor version (e.g., 3.13) to install the correct venv package
PY_MAJOR_MINOR=$(python3 -c "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}')")

# Install the python3.x-venv package if it's not already available
sudo apt-get install -y python$PY_MAJOR_MINOR-venv

# Define the location of the virtual environment
VENV_DIR="$HOME/.venvs/django-env"

# Create a virtual environment for Django
python3 -m venv "$VENV_DIR"

# Upgrade pip inside the virtual environment
"$VENV_DIR/bin/pip" install --upgrade pip

# Install Django inside the virtual environment
"$VENV_DIR/bin/pip" install django

# Verify that Django was installed successfully
if "$VENV_DIR/bin/python" -m django --version &> /dev/null; then
  DJANGO_VERSION=$("$VENV_DIR/bin/python" -m django --version)
  echo -e "${GREEN}✅ Django installed in venv (version: $DJANGO_VERSION).${NC}"
  echo -e "${GREEN}💡 To activate the Django environment, run:${NC}"
  echo -e "${GREEN}   source $VENV_DIR/bin/activate${NC}"
else
  echo -e "${RED}❌ Django installation failed in venv.${NC}"
fi

echo -e "${GREEN}🎉 All required tools are installed successfully!${NC}"