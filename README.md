# Ansible NDFC VXLAN Example Repository

This repository is designed to build the skeleton for the Network as Code DC VXLAN Ansible Galaxy collection. Cloaning this repository will create a working structure that you can build upon to automate your Cisco Nexus Data Center network using NDFC.

## Setting up environment for the collection

The first procedure for execution of the collection is going to be the installation of a virtual environment to be able to install the collection and it's requirements. Recomendation is to utilize [pyenv](https://github.com/pyenv/pyenv) which provides a robust python virtual environment capability that also includes management of python versions. These instructions will be detailed around pyenv. For the pipeline execution please refer to *pipeline section* where it is documented at container level.

### Step 1 - Installing the example repository

To simplify the usage of the collection we are providing you with an [example repository](https://github.com/netascode/ansible-dc-vxlan-example) that you can clone from github which creates the proper skeleton required, including examples for pipelines. Cloaning this repository requires the installation of [git client](https://git-scm.com/downloads) that is available for all platforms.

Run the following command in the location of interest.

```bash
git clone https://github.com/netascode/ansible-dc-vxlan-example.git nac-vxlan
```

This will clone the repository into the directory nac-vxlan.

### Step 2 - Create the virtual environment with pyenv

In this directory you will now create the new virtual environment and install a python version of your choice. At the _time of this writting_, a commonly used version is python version 3.10.13.  Command `pyenv install 3.10.13` will install this version. For detailed instructions please visit the [pyenv](https://github.com/pyenv/pyenv) site.

```bash
cd nac-vxlan
pyenv virtualenv <python_version> nac-ndfc
pyenv local nac-ndfc
```

The final command is `pyenv local` which sets the environment so that whenever you enter the directory it will change into the right virtual environment.

### Step 3 - Install Ansible and additional required tools

Included in the example repository is the requirements file to install ansible. First upgrade PIP to latest version.

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 4 - Install Ansible Galaxy Collection (default placement)

The default placement of the ansible galaxy collections would be in your home directory under `.ansible/collections/ansible_collections/`. To install the collection in the default location run the following command:

```bash
ansible-galaxy collection install -r requirements.yml
```

### Step 5 - Install Ansible Galaxy collection (non-default placement)

If you wish to install the galaxy collection inside the repository you are creating with this example repository, you can run the following command:

```bash
ansible-galaxy collection install -p collections/ansible_collections/ -r requirements.yml
```

You will need to then configure your ansible.cfg file to point to the correct location of the collection. 

This sets the correct path for all the python modules and libraries in the virtual environment that was created. If you look in that directory you will find the collections package locations. Here is the base ansible.cfg, you will need to adjust the collection_path to your environment paths:

```bash
[defaults]
collections_path = ./collections/ansible_collections/

```

### Step 6 - Change Ansible callbacks

If you wish to add any ansible callbacks ( the listed below expand on displaying time execution ) you can add the following to the ansible.cfg file:

```ini
callback_whitelist=ansible.posix.timer,ansible.posix.profile_tasks,ansible.posix.profile_roles
callbacks_enabled=ansible.posix.timer,ansible.posix.profile_tasks,ansible.posix.profile_roles
bin_ansible_callbacks = True
```

### Step 7 - Verify the installation

Verify that the ansible configuration file is being read and all the paths are correct inside of this virtual environment. 

```bash
ansible --version
```

Your output should be similar to the output below

```bash
ansible [core 2.16.3]
  config file = /Users/username/tmp/nac-vxlan/ansible.cfg
  configured module search path = ['/Users/username/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/username/.pyenv/versions/3.10.13/envs/nac-ndfc/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/username/path/to/collections/ansible_collections
  executable location = /Users/username/.pyenv/versions/nac-ndfc/bin/ansible
  python version = 3.10.13 (main, Oct 29 2023, 00:04:17) [Clang 15.0.0 (clang-1500.0.40.1)] (/Users/username/.pyenv/versions/3.10.13/envs/nac-ndfc/bin/python3.10)
  jinja version = 3.1.4
  libyaml = True
```

## Inventory host files

As is standard with Ansible best practices, inventory files provide the destination targets for the automation. For this collection, the inventory file is a YAML file that contains the information about the devices that are going to be configured. The inventory files is called `inventory.yml` and is located in the root of the repository.

The inventory file is going to contain a structure similar to this:

```yaml
---
all:
  children:
    ndfc:
      hosts:
        nac-ndfc1:
          ansible_host: 10.X.X.X
```

This structure creates two things in Ansible, a group called `ndfc` and a host called `nac-ndfc1:`. These are tied back to the directory structure of the repository that contains two folders in the top directory:

```mermaid
graph
  root-->group_vars
  root-->host_vars
  group_vars-->ndfc
  ndfc-->connection.yml
  host_vars-->nac-ndfc1
  nac-ndfc1-->data_model_files
```

The data model is **required** to exist under the `host_vars` directory structure. The inventory file is organizing how the variables are read through both the group_vars and the host_vars. Under the group_vars is where you will set the `connection.yml` file that has the credentials of the NDFC controller. Under the `host_vars` is where we will place the inventory.

The collection is **pre-built** to utilize the `group_vars` and `host_vars` matching what is already constructed in the repository. Currently this methodology is a 1:1 relationship between code repository and NDFC fabric. For more complex environments, the inventory file can be expanded to include multiple groups and hosts including the usage of multi-site fabrics, explained in a separate document.

### Step 1 - Update the inventory file

In the provided `inventory.yml` file on the root directory, update the `ansible_host` variable to point to your NDFC controller by replacing `10.X.X.X` with the IP address of the NDFC controller.


### Step 2 - Configure ansible connection file

In the directory `group_vars/ndfc` is a file called `connection.yml` that contains example data as:

```yaml
---
# Connection Parameters for 'ndfc' inventory group
#
# Controller Credentials
ansible_connection: ansible.netcommon.httpapi
ansible_httpapi_port: 443
ansible_httpapi_use_ssl: true
ansible_httpapi_validate_certs: false
ansible_network_os: cisco.dcnm.dcnm
# NDFC API Credentials
ansible_user: "{{ lookup('env', 'ansible_user') }}"
ansible_password: "{{ lookup('env', 'ansible_password') }}"
# Credentials for devices in Inventory
ndfc_device_username: "{{ lookup('env', 'ndfc_device_username') }}"
ndfc_device_password: "{{ lookup('env', 'ndfc_device_password') }}"

```

This file is going to contain the connection parameters for reachability to the NDFC controller. The `ansible_user`, and `ansible_password` are set to establish connection to the NDFC controller. For the devices, you will set separate variables also configured as environment variables. The usage of environment variables is done for security reasons, so that the credentials are not stored in plain text in the repository. Accidentaly including your credentials in a repository is a very hard to remove. Hence, the usage of environment variables is recommended as a starting point.

Also if you plan to eventually utilize a pipeline, the environment variables can be set in the pipeline configuration in a secure manner that is not exposed to the repository.

The usage of [Ansible vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html) is also possible to encrypt the contents of the connection file or simply encrypt the variables.

### Step 3 - Set environment variables

The environment variables are set in the shell that is going to execute the playbook. The environment variables are configured via the `export` command in the shell (bash). Using this template set the environment variables to the correct credentials for the NDFC controller and the devices in the inventory on your topology.

```bash
# These are the credentials for 
export ansible_user=admin
export ansible_password=Admin_123
# These are the credentials for the devices in the inventory
export ndfc_device_username=admin
export ndfc_device_password=Admin_123
```

## Understanding our Ansible roles

### Validate role

Role: [cisco.nac_dc_vxlan.validate](https://github.com/netascode/ansible-dc-vxlan/blob/develop/roles/validate/README.md)

The validate role function is to ensure that the data model is correct and that the data model is going to be able to be processed by the subsequent roles. The validate role is going to read all the files in the `host_vars` directory and create a single data model in memory for execution.

As part of the VXLAN as Code service from Cisco, you will also be able to utilize the semantic validation to make sure that the data model matches the intended expected values. This is a powerful feature that allows you to ensure that the data model is correct before it is deployed to the network. Also part of the validate role is the ability to create rules that can be used to avoid operators from making specific configurations that are not allowed in the network. These can be as simple as ensuring naming convention to more complex rules for interconnectivity that would need to be avoided. These would be coded in python and can be constructed as part of the Services as Code offer. 

### Create role

Role: [cisco.nac_dc_vxlan.dtc.create](https://github.com/netascode/ansible-dc-vxlan/blob/develop/roles/dtc/create/README.md)

This role is going to create all the templates and variable parameters that are going to be used in the deployment of the VXLAN fabric. This role converts the data model into the proper templates that are required by the Ansible module to be able to communicate with the NDFC controller.

### Deploy role

Role: [cisco.nac_dc_vxlan.dtc.deploy](https://github.com/netascode/ansible-dc-vxlan/blob/develop/roles/dtc/deploy/README.md)

The deploy role is going to deploy those changes to the NDFC controller. This role is going to take the templates and variable parameters that were created in the `create` role and deploy them to the NDFC controller. This is the role that is going to make the changes in the NDFC controller.

### Remove role

Role: [cisco.nac_dc_vxlan.dtc.remove](https://github.com/netascode/ansible-dc-vxlan/blob/develop/roles/dtc/remove/README.md)

The remove role is the opposite of the deploy role and removes what is represented in the data model from the NDFC controller. For this reason this role requires the settings of some variables to true under the `group_vars` directory. This is to avoid accidental removal of configuration from NDFC that might impact the network.

Inside the example repository under `group_vars/ndfc` is a file called `ndfc.yml` that contains some variables that need to be set to true to allow the removal of the configuration from the NDFC controller. The variables are:

```yaml
# Parameters for the tasks in the 'Remove' role
interface_delete_mode: false
network_delete_mode: false
vrf_delete_mode: false
inventory_delete_mode: false
vpc_peering_delete_mode: false
```

These variables are set to false by default to avoid accidental removal of configuration from NDFC that might impact the network. 

### Advantages of the roles in the workflow

The primary advantage of the workflow is that you can insert these in different parts of the data model preparation and changes without having to worry about impacts to the network. The roles are designed to be idempotent and only make changes when there are changes in the data model. For different stages of changes in the network, you can comment out the roles that are not required to be executed. Leaving the final full execution potentially to only happen from a pipeline, yet allow for operators to validate changes before they are executed.

## Building the primary playbook

The playbook for the NDFC as Code collection is the execution point of the this automation collection. In difference to other automation with collections, what is in this playbook is mostly static and not going to change. What is executed during automation is based on changes in the data model. Hence as changes happen in the data model, the playbook will call the modules and based on what has changed in the data model, is what is going to execute.

The playbook is located in the root of the repository and is called `vxlan.yml`. It contains the following:

```yaml
---
# This is the main entry point playbook for calling the various
# roles in this collection.
- hosts: nac-ndfc1
  any_errors_fatal: true
  gather_facts: no

  roles:
    # Prepare service model for all subsequent roles
    #
    - role: cisco.nac_dc_vxlan.validate

    # -----------------------
    # DataCenter Roles
    #   Role: cisco.netascode_dc_vxlan.dtc manages direct to controller NDFC workflows
    #
    - role: cisco.nac_dc_vxlan.dtc.create
    - role: cisco.nac_dc_vxlan.dtc.deploy
    - role: cisco.nac_dc_vxlan.dtc.remove
```

The `host` is defined as nac-ndfc1 which references back to the inventory file. The `roles` section is where the collection is going to be called.

The first role is `cisco.nac_dc_vxlan.validate` which is going to validate the data model. This is a required step to ensure that the data model is correct and that the data model is going to be able to be processed by the subsequent roles.

The next roles are the `cisco.nac_dc_vxlan.dtc.create`, `cisco.nac_dc_vxlan.dtc.deploy`, and `cisco.nac_dc_vxlan.dtc.remove`. These roles are the primary roles that will invoke change in NDFC. The `create` role is going to create all the templates and variable parameters . The `deploy` role is going to deploy those changes to the NDFC controller. The `remove` role would remove the data model from the devices in the inventory.

> **Note**: For your safety, the `remove` role also requires settings some variables to true under the `group_vars` directory. This is to avoid accidental removal of configuration from NDFC that might impact the network. This will be covered in a section below.


Since each of these roles are separte, you may configure the playbook to only execute the roles that are required. For example, as you are building your data model and getting to know the collection, you may comment out the `deploy` and `remove` roles to only execute the `validate` and `create` role. This provides a quick way to make sure that the data model is structured correctly.


### Global configuration

The first file we are going to create is going be called `global.yml` and is going to contain the global parameters for the VXLAN fabric.

```yaml
---
vxlan:
  global:
    name: nac-ndfc1
    bgp_asn: 65001
    route_reflectors: 2
    anycast_gateway_mac: 12:34:56:78:90:00
    dns_servers:
      - ip_address: 10.x.x.x
        vrf: management
    ntp_servers:
      - ip_address: 10.x.x.x
        vrf: management
```

### Topology inventory configuration

This file will be named `topology_switches.yml`. Here you will configure the base topology inventory of the switches in the fabric. 

```yaml
---
vxlan:
  topology:
    switches:
      - name: spine1
        serial_number: 99H2TUPCVFK
        role: spine
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.0.0.11
        routing_loopback_id: 0
        vtep_loopback_id: 1
      - name: spine2
        serial_number: 941L30Q8ZYI
        role: spine
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.0.0.12
        routing_loopback_id: 0
        vtep_loopback_id: 1
      - name: leaf1
        serial_number: 9LWGEUPJOCM
        role: leaf
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.1.1.13
        routing_loopback_id: 0
        vtep_loopback_id: 1
      - name: leaf2
        serial_number: 9YEXD0OHA7Z
        role: leaf
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.1.1.14
        routing_loopback_id: 0
        vtep_loopback_id: 1
      - name: leaf3
        serial_number: 9M2TXMZ7D3N
        role: leaf
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.1.1.15
        routing_loopback_id: 0
        vtep_loopback_id: 1
      - name: leaf4
        serial_number: 982YGMKUY2B
        role: leaf
        management:
          default_gateway_v4: 10.1.1.1
          management_ipv4_address: 10.1.1.16
        routing_loopback_id: 0
        vtep_loopback_id: 1
```

### Underlay configuration

This file will be named `underlay.yml`. Here you will configure the base topology inventory of the switches in the fabric. 

```yaml
---
vxlan:
  underlay:
    general:
      routing_protocol: ospf
      enable_ipv6_underlay: false
      replication_mode: multicast
      fabric_interface_numbering: p2p
      subnet_mask: 31
      underlay_routing_loopback_id: 0
      underlay_vtep_loopback_id: 1
      underlay_routing_protocol_tag: UNDERLAY
      underlay_rp_loopback_id: 250
      intra_fabric_interface_mtu: 9216
      layer2_host_interfacde_mtu: 9216
      unshut_host_interfaces: true
    ipv4:
      underlay_routing_loopback_ip_range: 10.0.0.0/22
      underlay_vtep_loopback_ip_range: 10.100.100.0/22
      underlay_rp_loopback_ip_range: 10.250.250.0/24
      underlay_subnet_ip_range: 10.1.0.0/16
    ipv6:
      enable_ipv6_link_local_address: false
      underlay_subnet_mask: 64
    ospf:
      area_id: 0.0.0.0
      authentication_enable: false
      authentication_key_id: 0
      authentication_key: ""
    multicast:
      underlay_rp_loopback_id: 250
      underlay_primary_rp_loopback_id: 0
```

### VRF configuration

This file will be named `vrfs.yml`. Here you will configure the base topology inventory of the switches in the fabric. 

```yaml
---
vxlan:
  overlay_services:
    vrfs:
      - name: NaC-ND2-VRF01
        vrf_id: 150001
        vlan_id: 2001
        attach_group: all
      - name: NaC-ND2-VRF02
        vrf_id: 150002
        vlan_id: 2002
        attach_group: leaf1
      - name: NaC-ND2-VRF03
        vrf_id: 150003
        vlan_id: 2003
        attach_group: leaf2
    vrf_attach_groups:
      - name: all
        switches:
          - { hostname: 10.1.1.13 }
          - { hostname: 10.1.1.14 }
          - { hostname: 10.1.1.15 }
          - { hostname: 10.1.1.16 }
      - name: leaf1
        switches:
          - { hostname: 10.1.1.13 }
      - name: leaf2
        switches:
          - { hostname: 10.1.1.14 }
      - name: leaf3
        switches:
          - { hostname: 10.1.1.15 }
      - name: leaf4
        switches:
          - { hostname: 10.1.1.16 }
```


### Network configuration

This file will be named `networks.yml`. Here you will configure the base topology inventory of the switches in the fabric. 

```yaml
---
vxlan:
  overlay_services:
    networks:
      - name: NaC-ND2-Net01
        vrf_name: NaC-ND2-VRF01
        net_id: 130001
        vlan_id: 2301
        vlan_name: NaC-ND2-Net01_vlan2301
        gw_ip_address: "192.168.12.1/24"
        attach_group: all
      - name: NaC-ND2-Net02
        vrf_name: NaC-ND2-VRF02
        # is_l2_only: True
        net_id: 130002
        vlan_id: 2302
        vlan_name: NaC-ND2-Net02_vlan2302
        gw_ip_address: "192.168.12.2/24"
        attach_group: leaf1
      - name: NaC-ND2-Net03
        vrf_name: NaC-ND2-VRF03
        net_id: 130003
        vlan_id: 2303
        vlan_name: NaC-ND2-Net03_vlan2303
        gw_ip_address: "192.168.12.3/24"
        gw_ipv6_address: "2001::1/64"
        route_target_both: True
        l3gw_on_border: True
        mtu_l3intf: 7600
        int_desc: "Configured by NetAsCode"
        attach_group: leaf2
    network_attach_groups:
      - name: all
        switches:
          - { hostname: 10.1.1.13, ports: [Ethernet1/13, Ethernet1/14] }
          - { hostname: 10.1.1.14, ports: [Ethernet1/13, Ethernet1/14] }
      - name: leaf1
        switches:
          - { hostname: 10.1.1.13, ports: [] }
      - name: leaf2
        switches:
          - { hostname: 10.1.1.14, ports: [] }
```

## Running the Playbook

Once you have completed the steps above, the playbook can be run using the following command from the root directory of the repository.

```bash
ansible-playbook -i inventory.yml vxlan.yml
```
