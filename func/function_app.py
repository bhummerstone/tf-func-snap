import azure.functions as func
import logging
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.storage.blob import BlobServiceClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="funcsnap")
def funcsnap(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    subscription_id = req.params.get('subID')
    resource_group = req.params.get('resGrp')
    disk_name = req.params.get('diskName')
    snapshot_name = req.params.get('snapName')
    #keyvault_name = req.params.get('keyVaultName')
    #key_name = req.params.get('keyName')

    logging.info(f"Subscription ID: {subscription_id}")
    logging.info(f"Resource Group: {resource_group}")
    logging.info(f"Disk Name: {disk_name}")
    logging.info(f"Snapshot Name: {snapshot_name}")
    #logging.info(f"Key Vault Name: {keyvault_name}")
    #logging.info(f"Key Name: {key_name}")

    # Create a credential object using the DefaultAzureCredential class
    credential = DefaultAzureCredential()

    # Create a blob service client
    blob_service_client = BlobServiceClient(account_url, credential=default_credential)

    # Create a compute management client
    compute_client = ComputeManagementClient(credential, subscription_id)

    # Get the disk that you want to create a snapshot of
    disk = compute_client.disks.get(resource_group, disk_name)
    
    # Create a snapshot config
    snapshot_config = compute_client.snapshots.models.Snapshot(
        location=disk.location,
        creation_data={
            "create_option": "Copy",
            "source_uri": disk.id
        }
        # Enable encryption
        #encryption_settings_collection={
        #    "enabled": True,
        #    "encryption_settings": [
        #        {
        #            "disk_encryption_key": {
        #                "source_vault": "<Your Key Vault>",
        #                "key_url": "<Your Key URL>"
        #            },
        #            "key_encryption_key": {
        #                "source_vault": "<Your Key Vault>",
        #                "key_url": "<Your Key URL>"
        #            }
        #        }
        #    ]
        #}
    )

    # Create the snapshot
    snapshot_operation = compute_client.snapshots.begin_create_or_update(
        resource_group,
        snapshot_name,
        snapshot_config
    )

    # Wait for the operation to complete
    snapshot_operation.wait()
    
    return func.HttpResponse(f"Snapshot {snapshot_name} created successfully.")
    status_code=200