export-envs:
	export APP_SA=dataproc-trigger-sa@my-project.iam.gserviceaccount.com
	export APP_IMAGE_NAME=dataproc-trigger-app

	export PYTHON_FILE_URL=gs://mydataproc-bucket/scripts/job.py
	export SOURCE_INPUT_LOCATION=gs://mydataproc-bucket/raw/
	export TARGET_OUTPUT_LOCATION=gs://mydataproc-bucket/processed/

sanity-check-bucket:
	gsutil ls gs://mydataproc-bucket/scripts/
	gsutil ls gs://mydataproc-bucket/raw/
	gsutil ls gs://mydataproc-bucket/processed/
