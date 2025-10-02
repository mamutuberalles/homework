terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  required_version = ">= 1.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "homework" {
  metadata {
    name = "homework-deployment"
    labels = {
      app = "homework"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "homework"
      }
    }

    template {
      metadata {
        labels = {
          app = "homework"
        }
      }

      spec {
        container {
          name  = "homework"
          image = "mamutuberalles/homework:latest"

          port {
            container_port = 8080
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 180
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 180
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "homework" {
  metadata {
    name = "homework-service"
    labels = {
      app = "homework"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "homework"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
  }
}