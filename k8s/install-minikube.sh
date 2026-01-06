#!/bin/bash

# Minikube üzerinde OpenTelemetry stack kurulum scripti

set -e

echo "🚀 Minikube OpenTelemetry Stack Kurulumu"
echo "========================================"

# Minikube kontrolü
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube yüklü değil. Lütfen minikube'u yükleyin."
    exit 1
fi

# Minikube'ün çalışıp çalışmadığını kontrol et
if ! minikube status &> /dev/null; then
    echo "📦 Minikube başlatılıyor..."
    minikube start --driver=docker
fi

echo "✓ Minikube çalışıyor"

# Docker env ayarla (local images için)
echo "🐳 Docker environment ayarlanıyor..."
eval $(minikube docker-env)

# Kubectl kontrol et
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl yüklü değil."
    exit 1
fi

echo "✓ kubectl hazır"

# Manifesto dosyalarının varlığını kontrol et
MANIFESTS=("otel-configmap.yaml" "jaeger.yaml" "otel-collector.yaml" "postgres.yaml" "deployment.yaml" "migration.yaml")
for manifest in "${MANIFESTS[@]}"; do
    if [ ! -f "k8s/$manifest" ]; then
        echo "❌ k8s/$manifest bulunamadı"
        exit 1
    fi
done

echo "✓ Tüm manifest dosyaları bulundu"

# Manifesto dosyalarını uygula
echo ""
echo "📋 Kubernetes kaynakları uygulanıyor..."
echo ""

echo "1/6 ConfigMap uygulanıyor..."
kubectl apply -f k8s/otel-configmap.yaml

echo "2/6 Jaeger uygulanıyor..."
kubectl apply -f k8s/jaeger.yaml

echo "3/6 OpenTelemetry Collector uygulanıyor..."
kubectl apply -f k8s/otel-collector.yaml

echo "4/6 PostgreSQL uygulanıyor..."
kubectl apply -f k8s/postgres.yaml

echo "5/6 Veritabanı migration uygulanıyor..."
kubectl apply -f k8s/migration.yaml

echo "6/6 Stock-Mgmt uygulaması uygulanıyor..."
kubectl apply -f k8s/deployment.yaml

echo ""
echo "✓ Tüm kaynaklar uygulandı"

# Pod'ların hazır olmasını bekle
echo ""
echo "⏳ Pod'ların başlaması bekleniyor (40 saniye)..."
sleep 40

# Pod durumunu kontrol et
echo ""
echo "📊 Pod Durumu:"
echo "Monitoring namespace:"
kubectl get pods -n monitoring
echo ""
echo "Default namespace:"
kubectl get pods

# Minikube IP'sini al
MINIKUBE_IP=$(minikube ip)

echo ""
echo "✅ Kurulum tamamlandı!"
echo ""
echo "🌐 Erişim Adresleri:"
echo "==================="
echo ""
echo "📊 Jaeger UI:              http://$MINIKUBE_IP:30686"
echo "📝 Stock-Mgmt API:         http://$MINIKUBE_IP"
echo "🔌 OTLP gRPC:              $MINIKUBE_IP:30317"
echo "🔌 OTLP HTTP:              $MINIKUBE_IP:30318"
echo ""
echo "💡 Kubernetes Dashboard:"
echo "   minikube dashboard"
echo ""
echo "📖 Logs görüntüle:"
echo "   kubectl logs -f deployment/jaeger -n monitoring"
echo "   kubectl logs -f deployment/otel-collector -n monitoring"
echo "   kubectl logs -f deployment/stock-mgmt -n default"
echo ""
echo "📊 Service'leri kontrol et:"
echo "   kubectl get svc -n monitoring"
echo "   kubectl get svc -n default"
echo ""
echo "🧹 Temizlik için:"
echo "   kubectl delete namespace monitoring"
echo "   kubectl delete deployment,service,configmap --all"
