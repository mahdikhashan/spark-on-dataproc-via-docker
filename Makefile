PROJECT_ID := spark-on-dataproc-487921
REGION := europe-west3
AF_REPO_NAME := my-docker-repo
IMAGE_NAME := spark-image
COMMIT_SHA := 3e185977
IMAGE_VERSION := 3e185977
PROCESS_BUCKET := mydataproc-bucket
SPARK_SA := dataproc-spark-worker@spark-on-dataproc-487921.iam.gserviceaccount.com

SUBNET := default

WORDCOUNT_SCRIPT := gs://mydataproc-bucket/scripts/wordcount.py
INPUT_BUCKET := gs://mydataproc-bucket/raw/
OUTPUT_BUCKET := gs://mydataproc-bucket/processed/

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

openssl-version:
	openssl version

generate-sample-text:
	openssl rand -out example/sample_1.txt -base64 $(( 2**28 * 3/4 ))

set-envs:
	export PROJECT_ID="spark-on-dataproc-487921"
	export REGION="europe-west3"
	export AF_REPO_NAME="my-docker-repo"
	export IMAGE_NAME="spark-image"
	export COMMIT_SHA=3e185975

verify-envs:
	echo $PROJECT_ID
	echo $AF_REPO_NAME
	echo $IMAGE_NAME
	echo $COMMIT_SHA

gcp-set-project:
	gcloud config set project spark-on-dataproc-487921

gcp-set-dataproc-region:
	gcloud config set dataproc/region europe-west3

gcp-enable-apis:
	gcloud services enable \
		artifactregistry.googleapis.com \
		cloudbuild.googleapis.com \
		dataproc.googleapis.com

gcp-create-af-repository:
	gcloud artifacts repositories create my-docker-repo \
	  --repository-format=docker \
	  --location=europe-west3

gcp-list-af:
	gcloud artifacts repositories list --location=europe-west3

gcp-verify-af-repository:
	gcloud artifacts repositories list --location=europe-west3

gcp-authenticate-af:
	gcloud auth configure-docker europe-west3-docker.pkg.dev

gcp-build-dataproc-image:
	gcloud builds submit \
		--config cloudbuild.yaml \
		--substitutions _PROJECT_ID=$(PROJECT_ID),_REPO_NAME=$(AF_REPO_NAME),_IMAGE_NAME=$(IMAGE_NAME),_COMMIT_SHA=$(COMMIT_SHA)

gcp-firewall-network:
	gcloud compute firewall-rules create allow-internal-ingress \
		--network="default" \
		--source-ranges="10.128.0.0/20" \
		--direction=INGRESS \
		--action=ALLOW \
		--rules=all

gcp-dataproc-submit-job:
	gcloud dataproc batches submit pyspark $(WORDCOUNT_SCRIPT) \
		--batch wordcount-$(shell date +"%Y%m%d-%H%M%S") \
		--project $(PROJECT_ID) \
		--region $(REGION) \
		--container-image "europe-west3-docker.pkg.dev/$(PROJECT_ID)/$(AF_REPO_NAME)/$(IMAGE_NAME):$(IMAGE_VERSION)" \
		--deps-bucket $(PROCESS_BUCKET) \
		--service-account $(SPARK_SA) \
		--subnet $(SUBNET) \
		--version 2.0 \
		--properties spark.dynamicAllocation.executorAllocationRatio=1.0,spark.dynamicAllocation.initialExecutors=3,spark.dynamicAllocation.minExecutors=3,spark.dynamicAllocation.maxExecutors=50 \
		-- $(INPUT_BUCKET) $(OUTPUT_BUCKET)