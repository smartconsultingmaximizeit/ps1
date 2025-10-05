- name: Enable WinRM over HTTPS using external script with CN parameter
  azure_rm_virtualmachineextension:
    resource_group: "{{ resource_group }}"
    name: "EnableWinRMHttps"
    virtual_machine_name: "{{ vm_vm_name }}"
    location: "{{ location }}"
    publisher: Microsoft.Compute
    virtual_machine_extension_type: CustomScriptExtension
    type_handler_version: "1.10"
    auto_upgrade_minor_version: true
    settings:
      fileUris:
        - "https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/enable-winrm-https.ps1"
      commandToExecute: >
        powershell -ExecutionPolicy Unrestricted -File enable-winrm-https.ps1 -cn "{{ winrm_host }}"
