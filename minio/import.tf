import {
  to = minio_s3_bucket.loki_data
  id = "s3-loki"
}

import {
  to = minio_s3_bucket.mimir_data
  id = "s3-mimir"
}

import {
  to = minio_s3_bucket.tempo_data
  id = "s3-tempo"
}

import {
  to = minio_s3_bucket.pyroscope_data
  id = "s3-pyroscope"
}

import {
  to = minio_s3_bucket.umami_data
  id = "s3-umami"
}

import {
  to = minio_iam_policy.loki_policy
  id = "loki-policy"
}

import {
  to = minio_iam_policy.mimir_policy
  id = "mimir-policy"
}

import {
  to = minio_iam_policy.tempo_policy
  id = "tempo-policy"
}

import {
  to = minio_iam_policy.pyroscope_policy
  id = "pyroscope-policy"
}

import {
  to = minio_iam_policy.umami_policy
  id = "umami-policy"
}
