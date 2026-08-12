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

import {
  to = minio_iam_user.loki_user
  id = data.doppler_secrets.this.map.S3_LOKI_ACCESS_KEY
}

import {
  to = minio_iam_user.mimir_user
  id = data.doppler_secrets.this.map.S3_MIMIR_ACCESS_KEY
}

import {
  to = minio_iam_user.tempo_user
  id = data.doppler_secrets.this.map.S3_TEMPO_ACCESS_KEY
}

import {
  to = minio_iam_user.pyroscope_user
  id = data.doppler_secrets.this.map.S3_PYROSCOPE_ACCESS_KEY
}

import {
  to = minio_iam_user.umami_user
  id = data.doppler_secrets.this.map.S3_UMAMI_ACCESS_KEY
}

import {
  to = minio_iam_user_policy_attachment.loki_attachment
  id = "${data.doppler_secrets.this.map.S3_LOKI_ACCESS_KEY}/loki-policy"
}

import {
  to = minio_iam_user_policy_attachment.mimir_attachment
  id = "${data.doppler_secrets.this.map.S3_MIMIR_ACCESS_KEY}/mimir-policy"
}

import {
  to = minio_iam_user_policy_attachment.tempo_attachment
  id = "${data.doppler_secrets.this.map.S3_TEMPO_ACCESS_KEY}/tempo-policy"
}

import {
  to = minio_iam_user_policy_attachment.pyroscope_attachment
  id = "${data.doppler_secrets.this.map.S3_PYROSCOPE_ACCESS_KEY}/pyroscope-policy"
}

import {
  to = minio_iam_user_policy_attachment.umami_attachment
  id = "${data.doppler_secrets.this.map.S3_UMAMI_ACCESS_KEY}/umami-policy"
}
