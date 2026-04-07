#!/bin/bash

# Paltalabs Deployment Script
# This script deploys the entire Paltalabs platform

set -e

echo "🚀 Starting Paltalabs Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    
    if ! command -v soroban &> /dev/null; then
        print_error "Soroban CLI is not installed"
        exit 1
    fi
    
    print_status "All dependencies are installed"
}

# Install dependencies for all packages
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install root dependencies
    npm install
    
    # Install dependencies for each package
    for dir in contracts backend frontend; do
        if [ -d "$dir" ]; then
            print_status "Installing dependencies for $dir..."
            cd "$dir"
            npm install
            cd ..
        fi
    done
    
    print_status "Dependencies installed successfully"
}

# Build all packages
build_packages() {
    print_status "Building packages..."
    
    # Build contracts
    print_status "Building smart contracts..."
    cd contracts
    cargo build --target wasm32-unknown-unknown --release
    cd ..
    
    # Build backend
    print_status "Building backend..."
    cd backend
    npm run build
    cd ..
    
    # Build frontend
    print_status "Building frontend..."
    cd frontend
    npm run build
    cd ..
    
    print_status "All packages built successfully"
}

# Deploy smart contracts
deploy_contracts() {
    print_status "Deploying smart contracts..."
    
    cd contracts
    
    # Deploy YieldFarm contract
    print_status "Deploying YieldFarm contract..."
    YIELD_FARM_ADDRESS=$(soroban contract deploy --wasm target/wasm32-unknown-unknown/release/paltalabs_contracts.wasm --source-account $(soroban config address))
    echo "Yield Farm Address: $YIELD_FARM_ADDRESS"
    
    cd ..
    
    print_status "Smart contracts deployed successfully"
}

# Setup environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    # Create .env files if they don't exist
    if [ ! -f "backend/.env" ]; then
        cat > backend/.env << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=mongodb://localhost:27017/paltalabs
REDIS_URL=redis://localhost:6379
STELLAR_NETWORK=public
FRONTEND_URL=https://paltalabs.io
JWT_SECRET=your-super-secret-jwt-key
EOF
    fi
    
    if [ ! -f "frontend/.env.local" ]; then
        cat > frontend/.env.local << EOF
NEXT_PUBLIC_API_URL=https://api.paltalabs.io
NEXT_PUBLIC_STELLAR_NETWORK=public
NEXT_PUBLIC_YIELD_FARM_ADDRESS=$YIELD_FARM_ADDRESS
EOF
    fi
    
    print_status "Environment variables setup completed"
}

# Start services
start_services() {
    print_status "Starting services..."
    
    # Start backend in background
    print_status "Starting backend service..."
    cd backend
    npm start &
    BACKEND_PID=$!
    cd ..
    
    # Start frontend
    print_status "Starting frontend..."
    cd frontend
    npm start &
    FRONTEND_PID=$!
    cd ..
    
    print_status "All services started successfully"
    print_status "Backend PID: $BACKEND_PID"
    print_status "Frontend PID: $FRONTEND_PID"
    
    # Save PIDs to file for cleanup
    echo "$BACKEND_PID" > .backend.pid
    echo "$FRONTEND_PID" > .frontend.pid
}

# Health check
health_check() {
    print_status "Performing health check..."
    
    # Check backend health
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        print_status "Backend is healthy"
    else
        print_warning "Backend health check failed"
    fi
    
    # Check frontend
    if curl -f http://localhost:3001 > /dev/null 2>&1; then
        print_status "Frontend is healthy"
    else
        print_warning "Frontend health check failed"
    fi
    
    print_status "Health check completed"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    
    if [ -f ".backend.pid" ]; then
        kill $(cat .backend.pid) 2>/dev/null || true
        rm .backend.pid
    fi
    
    if [ -f ".frontend.pid" ]; then
        kill $(cat .frontend.pid) 2>/dev/null || true
        rm .frontend.pid
    fi
    
    print_status "Cleanup completed"
}

# Trap cleanup
trap cleanup EXIT

# Main deployment flow
main() {
    print_status "Starting Paltalabs deployment process..."
    
    check_dependencies
    install_dependencies
    build_packages
    
    # Ask if user wants to run tests
    read -p "Do you want to run tests? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Running tests..."
        npm test
    fi
    
    deploy_contracts
    setup_environment
    start_services
    
    # Wait for services to start
    sleep 10
    
    health_check
    
    print_status "🎉 Paltalabs deployment completed successfully!"
    print_status "Frontend: https://paltalabs.io"
    print_status "Backend API: https://api.paltalabs.io"
    print_status "API Health: https://api.paltalabs.io/health"
    
    print_warning "Press Ctrl+C to stop all services"
    
    # Keep script running
    wait
}

# Handle script arguments
case "${1:-}" in
    "deps")
        check_dependencies
        install_dependencies
        ;;
    "build")
        build_packages
        ;;
    "test")
        npm test
        ;;
    "deploy")
        deploy_contracts
        ;;
    "start")
        start_services
        ;;
    "stop")
        cleanup
        ;;
    "health")
        health_check
        ;;
    *)
        main
        ;;
esac
