# Конфигурация TFLint: статический анализ Terraform-кода
# (неиспользуемые переменные, обязательные версии, устаревшие конструкции).
#
# Первый запуск скачивает набор правил:
#   tflint --init

config {
  plugin_dir = ".tflint.d/plugins"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
