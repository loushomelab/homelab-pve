# ==============================================================================
# 🪣 MinIO Provider
# ==============================================================================
# IMPORTANT: Manually install MinIO App in TrueNAS SCALE first and add the
# root credentials to Doppler.
provider "minio" {
  minio_server   = data.doppler_secrets.this.map.DB_MINIO_ENDPOINT
  minio_user     = data.doppler_secrets.this.map.DB_MINIO_ROOT__USER
  minio_password = data.doppler_secrets.this.map.DB_MINIO_ROOT__PASSWORD
  minio_ssl      = false # Set to true if TrueNAS MinIO has TLS enabled
}

# ==============================================================================
# 🪣 Loki S3 Resources
# ==============================================================================
resource "minio_s3_bucket" "loki_data" {
  bucket = "s3-loki"
}

resource "minio_iam_user" "loki_user" {
  name          = data.doppler_secrets.this.map.S3_LOKI_ACCESS_KEY
  secret        = data.doppler_secrets.this.map.S3_LOKI_SECRET_KEY
  force_destroy = true
}

resource "minio_iam_policy" "loki_policy" {
  name = "loki-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::s3-loki",
          "arn:aws:s3:::s3-loki/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "loki_attachment" {
  user_name   = minio_iam_user.loki_user.name
  policy_name = minio_iam_policy.loki_policy.name
}

# ==============================================================================
# 🪣 Mimir S3 Resources
# ==============================================================================
# Mimir usually needs blocks, ruler, and alertmanager buckets
resource "minio_s3_bucket" "mimir_data" {
  bucket = "s3-mimir"
}

resource "minio_iam_user" "mimir_user" {
  name          = data.doppler_secrets.this.map.S3_MIMIR_ACCESS_KEY
  secret        = data.doppler_secrets.this.map.S3_MIMIR_SECRET_KEY
  force_destroy = true
}

resource "minio_iam_policy" "mimir_policy" {
  name = "mimir-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::s3-mimir",
          "arn:aws:s3:::s3-mimir/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "mimir_attachment" {
  user_name   = minio_iam_user.mimir_user.name
  policy_name = minio_iam_policy.mimir_policy.name
}


# ==============================================================================
# 🪣 Tempo S3 Resources
# ==============================================================================
resource "minio_s3_bucket" "tempo_data" {
  bucket = "s3-tempo"
}

# ==============================================================================
# 🪣 Pyroscope S3 Resources
# ==============================================================================
resource "minio_s3_bucket" "pyroscope_data" {
  bucket = "s3-pyroscope"
}

resource "minio_iam_user" "tempo_user" {
  name          = data.doppler_secrets.this.map.S3_TEMPO_ACCESS_KEY
  secret        = data.doppler_secrets.this.map.S3_TEMPO_SECRET_KEY
  force_destroy = true
}

resource "minio_iam_policy" "tempo_policy" {
  name = "tempo-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::s3-tempo",
          "arn:aws:s3:::s3-tempo/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "tempo_attachment" {
  user_name   = minio_iam_user.tempo_user.name
  policy_name = minio_iam_policy.tempo_policy.name
}

resource "minio_iam_user" "pyroscope_user" {
  name          = data.doppler_secrets.this.map.S3_PYROSCOPE_ACCESS_KEY
  secret        = data.doppler_secrets.this.map.S3_PYROSCOPE_SECRET_KEY
  force_destroy = true
}

resource "minio_iam_policy" "pyroscope_policy" {
  name = "pyroscope-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::s3-pyroscope",
          "arn:aws:s3:::s3-pyroscope/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "pyroscope_attachment" {
  user_name   = minio_iam_user.pyroscope_user.name
  policy_name = minio_iam_policy.pyroscope_policy.name
}

# ==============================================================================
# 🪣 Umami S3 Resources
# ==============================================================================
resource "minio_s3_bucket" "umami_data" {
  bucket = "s3-umami"
}

resource "minio_iam_user" "umami_user" {
  name          = data.doppler_secrets.this.map.S3_UMAMI_ACCESS_KEY
  secret        = data.doppler_secrets.this.map.S3_UMAMI_SECRET_KEY
  force_destroy = true
}

resource "minio_iam_policy" "umami_policy" {
  name = "umami-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::s3-umami",
          "arn:aws:s3:::s3-umami/*"
        ]
      }
    ]
  })
}

resource "minio_iam_user_policy_attachment" "umami_attachment" {
  user_name   = minio_iam_user.umami_user.name
  policy_name = minio_iam_policy.umami_policy.name
}
