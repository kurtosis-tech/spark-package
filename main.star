SPARK_MASTER_SERVICE_NAME = "spark-master"
SPARK_WORKER_SERVICE_NAME_PREFIX = "spark-worker"
SPARK_IMAGE = "bitnami/spark:latest"
SPARK_CMD = "./sbin/start-master.sh"

SPARK_WEB_UI_PORT_NUMBER = 8080
SPARK_MASTER_PORT_NUMBER = 7077
NUM_WORKERS = 1


def run(plan, args={}):
    create_spark_master(plan)
    for idx in range(1, NUM_WORKERS + 1):
        create_spark_worker(plan, SPARK_MASTER_PORT_NUMBER, idx)


def create_spark_master(plan):
    config = ServiceConfig(
        image=SPARK_IMAGE,
        ports={
            "web-ui": PortSpec(
                number=SPARK_WEB_UI_PORT_NUMBER,
                transport_protocol="TCP",
                application_protocol="http",
            ),
            "master": PortSpec(
                number=SPARK_MASTER_PORT_NUMBER,
                transport_protocol="TCP",
                application_protocol="http",
            ),
        },
        env_vars={
            "SPARK_MODE": "master",
            "SPARK_RPC_AUTHENTICATION_ENABLED": "no",
            "SPARK_RPC_ENCRYPTION_ENABLED": "no",
            "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED": "no",
            "SPARK_SSL_ENABLED": "no",
            "SPARK_USER": "spark",
        },
    )
    plan.add_service(name=SPARK_MASTER_SERVICE_NAME, config=config)


def create_spark_worker(plan, master_port, idx):
    spark_worker_name = "%s-%d" % (SPARK_WORKER_SERVICE_NAME_PREFIX, idx)
    spark_master_url = "spark://%s:%d" % (SPARK_MASTER_SERVICE_NAME, master_port)
    config = ServiceConfig(
        image=SPARK_IMAGE,
        env_vars={
            "SPARK_MODE": "worker",
            "SPARK_MASTER_URL": spark_master_url,
            "SPARK_WORKER_MEMORY": "1G",
            "SPARK_WORKER_CORES": "1",
            "SPARK_RPC_AUTHENTICATION_ENABLED": "no",
            "SPARK_RPC_ENCRYPTION_ENABLED": "no",
            "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED": "no",
            "SPARK_SSL_ENABLED": "no",
            "SPARK_USER": "spark",
        },
    )
    plan.add_service(name=spark_worker_name, config=config)
