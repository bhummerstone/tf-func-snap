import azure.functions as func
import logging
import datetime
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
    snapshot_storage_account = req.params.get('snapStorageAccount')
    #keyvault_name = req.params.get('keyVaultName')
    #key_name = req.params.get('keyName')

    logging.info(f"Subscription ID: {subscription_id}")
    logging.info(f"Resource Group: {resource_group}")
    logging.info(f"Disk Name: {disk_name}")
    logging.info(f"Snapshot Name: {snapshot_name}")
    logging.info(f"Snapshot Storage Account: {snapshot_storage_account}")
    #logging.info(f"Key Vault Name: {keyvault_name}")
    #logging.info(f"Key Name: {key_name}")

    # Create a credential object using the DefaultAzureCredential class
    credential = DefaultAzureCredential()

    # Create a blob service client
    account_url = f"https://{snapshot_storage_account}.blob.core.windows.net"
    blob_service_client = BlobServiceClient(account_url, credential=credential)

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
    )

    # Create the snapshot
    snapshot_operation = compute_client.snapshots.begin_create_or_update(
        resource_group,
        snapshot_name,
        snapshot_config
    )

    # Wait for the operation to complete
    snapshot_operation.wait()

    # Create a name for the container
    container_name = datetime.date.today().strftime("%Y%m%d") + "snapshots"
    blob_service_client.create_container(container_name)

    snapshot_sas = compute_client.snapshots.begin_grant_access(
        resource_group,
        snapshot_name,
        access_duration=3600,
        access_level="Read"
    ).result()

    copy_id = blob_service_client.start_copy_from_url(snapshot_sas.access_sas, f"https://{snapshot_storage_account}.blob.core.windows.net/{container_name}/{snapshot_name}.vhd")
    
    return func.HttpResponse(f"Snapshot {snapshot_name} created successfully. Copy job started with ID {copy_id}")
    status_code=200