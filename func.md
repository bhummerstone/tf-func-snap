from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

# Replace these with your own values
subscription_id = "<Your Azure Subscription ID>"
resource_group = "<Your Resource Group>"
disk_name = "<Your Disk Name>"
snapshot_name = "<Your Snapshot Name>"

# Create a credential object using the DefaultAzureCredential class
credential = DefaultAzureCredential()

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
    },
    # Enable encryption
    encryption_settings_collection={
        "enabled": True,
        "encryption_settings": [
            {
                "disk_encryption_key": {
                    "source_vault": "<Your Key Vault>",
                    "key_url": "<Your Key URL>"
                },
                "key_encryption_key": {
                    "source_vault": "<Your Key Vault>",
                    "key_url": "<Your Key URL>"
                }
            }
        ]
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