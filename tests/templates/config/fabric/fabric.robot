# This is a simplified version of the robot test for demonstration purposes.

*** Settings ***
Documentation    Verify Fabric
Resource         ../../ndfc_common.resource
Library          String
Suite Setup      Login NDFC
Default Tags     ndfc    day2    config    fabric

{% set fabric = vxlan.fabric.name %}

*** Test Cases ***
Get All Parameters from Fabric {{ fabric }}
    ${r}=   GET On Session   ndfc   /appcenter/cisco/ndfc/api/v1/lan-fabric/rest/control/fabrics/{{ fabric }}
    Set Suite Variable  ${r}

Verify Fabric {{ fabric }} Global Parameters
    Should Be Equal Value Json String   ${r.json()}   $..FABRIC_NAME   {{ fabric }}   msg=name
    Should Be Equal Value Json String   ${r.json()}   $..BGP_AS   {{ vxlan.global.ibgp.bgp_asn }}   msg=bgp_asn
    Should Be Equal Value Json String   ${r.json()}   $..fabricType   Switch_Fabric   msg=fabricType
    Should Be Equal Value Json String   ${r.json()}   $..OVERLAY_MODE   cli   msg=OVERLAY_MODE
    Should Be Equal Value Json String   ${r.json()}   $..GRFIELD_DEBUG_FLAG   Enable   msg=GRFIELD_DEBUG_FLAG

Verify Fabric {{ fabric }} Underlay General Parameters
    Should Be Equal Value Json String   ${r.json()}   $..BGP_LB_ID   {{ vxlan.underlay.general.underlay_routing_loopback_id | default(defaults.vxlan.underlay.general.underlay_routing_loopback_id) }}   msg=BGP_LB_ID
    Should Be Equal Value Json String   ${r.json()}   $..NVE_LB_ID   {{ vxlan.underlay.general.underlay_vtep_loopback_id | default(defaults.vxlan.underlay.general.underlay_vtep_loopback_id) }}   msg=NVE_LB_ID
    Should Be Equal Value Json String   ${r.json()}   $..FABRIC_MTU   {{ vxlan.underlay.general.intra_fabric_interface_mtu | default(defaults.vxlan.underlay.general.intra_fabric_interface_mtu) }}   msg=FABRIC_MTU

Verify Fabric {{ fabric }} Underlay Multicast Parameters
    Should Be Equal Value Json String   ${r.json()}   $..REPLICATION_MODE   {{ vxlan.underlay.general.replication_mode | default(defaults.vxlan.underlay.general.replication_mode) | title }}   msg=REPLICATION_MODE
{% if (vxlan.underlay.general.replication_mode | default(defaults.vxlan.underlay.general.replication_mode) | title) == 'Multicast' %}
    Should Be Equal Value Json String   ${r.json()}   $..MULTICAST_GROUP_SUBNET   {{ vxlan.underlay.multicast.ipv4.group_subnet | default(defaults.vxlan.underlay.multicast.ipv4.group_subnet) }}   msg=MULTICAST_GROUP_SUBNET
    Should Be Equal Value Json String   ${r.json()}   $..RP_COUNT   {{ vxlan.underlay.multicast.rendezvous_points | default(defaults.vxlan.underlay.multicast.rendezvous_points) }}   msg=RP_COUNT
    Should Be Equal Value Json String   ${r.json()}   $..RP_MODE   {{ vxlan.underlay.multicast.rp_mode | default(defaults.vxlan.underlay.multicast.rp_mode) }}   msg=RP_MODE
    Should Be Equal Value Json String   ${r.json()}   $..RP_LB_ID   {{ vxlan.underlay.multicast.underlay_rp_loopback_id | default(defaults.vxlan.underlay.multicast.underlay_rp_loopback_id) }}   msg=RP_LB_ID
    Should Be Equal Value Json String   ${r.json()}   $..ENABLE_TRM   {{ (vxlan.underlay.multicast.ipv4.trm_enable | default(defaults.vxlan.underlay.multicast.ipv4.trm_enable) | lower) }}   msg=ENABLE_TRM
{% if (vxlan.underlay.multicast.ipv4.trm_enable | default(defaults.vxlan.underlay.multicast.ipv4.trm_enable) | lower) == 'true' %}
    Should Be Equal Value Json String   ${r.json()}   $..L3VNI_MCAST_GROUP     {{ vxlan.underlay.multicast.ipv4.trm_default_group | default(defaults.vxlan.underlay.multicast.ipv4.trm_default_group) }}
{% endif %}
{% if vxlan.underlay.multicast.rp_mode | default(defaults.vxlan.underlay.multicast.rp_mode) == 'bidir' %}
    Should Be Equal Value Json String   ${r.json()}   $..PHANTOM_RP_LB_ID1   {{ vxlan.underlay.multicast.underlay_primary_rp_loopback_id | default(defaults.vxlan.underlay.multicast.underlay_primary_rp_loopback_id) }}   msg=PHANTOM_RP_LB_ID1
    Should Be Equal Value Json String   ${r.json()}   $..PHANTOM_RP_LB_ID2   {{ vxlan.underlay.multicast.underlay_backup_rp_loopback_id | default(defaults.vxlan.underlay.multicast.underlay_backup_rp_loopback_id) }}   msg=PHANTOM_RP_LB_ID2
{% if vxlan.underlay.multicast.rendezvous_points | default(defaults.vxlan.underlay.multicast.rendezvous_points) == 4 %}
    Should Be Equal Value Json String   ${r.json()}   $..PHANTOM_RP_LB_ID3   {{ vxlan.underlay.multicast.underlay_second_backup_rp_loopback_id | default(defaults.vxlan.underlay.multicast.underlay_second_backup_rp_loopback_id) }}   msg=PHANTOM_RP_LB_ID3
    Should Be Equal Value Json String   ${r.json()}   $..PHANTOM_RP_LB_ID4   {{ vxlan.underlay.multicast.underlay_third_backup_rp_loopback_id | default(defaults.vxlan.underlay.multicast.underlay_third_backup_rp_loopback_id) }}   msg=PHANTOM_RP_LB_ID4
{% endif %}
{% endif %}
{% endif %}

Verify Fabric {{ fabric }} Underlay IPv4 Parameters 
    Should Be Equal Value Json String   ${r.json()}   $..STATIC_UNDERLAY_IP_ALLOC   {{ (vxlan.underlay.general.manual_underlay_allocation | default(defaults.vxlan.underlay.general.manual_underlay_allocation) | lower)}}   msg=STATIC_UNDERLAY_IP_ALLOC
{% if (vxlan.underlay.general.manual_underlay_allocation | default(defaults.vxlan.underlay.general.manual_underlay_allocation) | lower) == 'false' %}
    Should Be Equal Value Json String   ${r.json()}   $..LOOPBACK0_IP_RANGE   {{ vxlan.underlay.ipv4.underlay_routing_loopback_ip_range | default(defaults.vxlan.underlay.ipv4.underlay_routing_loopback_ip_range) }}   msg=LOOPBACK0_IP_RANGE
    Should Be Equal Value Json String   ${r.json()}   $..LOOPBACK1_IP_RANGE   {{ vxlan.underlay.ipv4.underlay_vtep_loopback_ip_range | default(defaults.vxlan.underlay.ipv4.underlay_vtep_loopback_ip_range) }}   msg=LOOPBACK1_IP_RANGE
    Should Be Equal Value Json String   ${r.json()}   $..SUBNET_RANGE     {{ vxlan.underlay.ipv4.underlay_subnet_ip_range | default(defaults.vxlan.underlay.ipv4.underlay_subnet_ip_range) }}   msg=SUBNET_RANGE
{% endif %}
{% if (vxlan.underlay.general.manual_underlay_allocation | default(defaults.vxlan.underlay.general.manual_underlay_allocation) | lower) == 'true' %}
    Should Be Equal Value Json String   ${r.json()}   $..ANYCAST_RP_IP_RANGE     {{ vxlan.underlay.ipv4.underlay_rp_loopback_ip_range | default(defaults.vxlan.underlay.ipv4.underlay_rp_loopback_ip_range) }}   msg=ANYCAST_RP_IP_RANGE
{% endif %}

Verify Fabric {{ fabric }} Underlay IPv6 Parameters
    Should Be Equal Value Json String   ${r.json()}   $..UNDERLAY_IS_V6   {{ (vxlan.underlay.general.enable_ipv6_underlay | default(defaults.vxlan.underlay.general.enable_ipv6_underlay) | lower) }}   msg=UNDERLAY_IS_V6
{% if (vxlan.underlay.general.enable_ipv6_underlay | default(defaults.vxlan.underlay.general.enable_ipv6_underlay) | lower) == 'true' %}
    Should Be Equal Value Json String   ${r.json()}   $..USE_LINK_LOCAL     {{ vxlan.underlay.ipv6.enable_ipv6_link_local_address | default(defaults.vxlan.underlay.ipv6.enable_ipv6_link_local_address | lower) }}   msg=USE_LINK_LOCAL
{% if (vxlan.underlay.ipv6.enable_ipv6_link_local_address | default(defaults.vxlan.underlay.ipv6.enable_ipv6_link_local_address) | lower) == 'false' %}
    Should Be Equal Value Json String   ${r.json()}   $..V6_SUBNET_TARGET_MASK     {{ vxlan.underlay.ipv6.underlay_subnet_mask | default(defaults.vxlan.underlay.ipv6.underlay_subnet_mask) }}   msg=V6_SUBNET_TARGET_MASK
{% endif %}
{% endif %}

Verify Fabric {{ fabric }} Underlay BGP Parameters
    Should Be Equal Value Json String   ${r.json()}   $..BGP_AUTH_ENABLE   {{ (vxlan.underlay.bgp.authentication_enable | default(defaults.vxlan.underlay.bgp.authentication_enable) | lower)}}   msg=BGP_AUTH_ENABLE
{% if (vxlan.underlay.bgp.authentication_enable | default(defaults.vxlan.underlay.bgp.authentication_enable) | lower) == 'true' %}
    Should Be Equal Value Json String   ${r.json()}   $..BGP_AUTH_KEY_TYPE     {{ vxlan.underlay.bgp.authentication_key_type | default(defaults.vxlan.underlay.bgp.authentication_key_type) }}   msg=BGP_AUTH_KEY_TYPE
    Should Be Equal Value Json String   ${r.json()}   $..BGP_AUTH_KEY     {{ vxlan.underlay.bgp.authentication_key | default(omit) }}   msg=BGP_AUTH_KEY
{% endif %}
{% if not (vxlan.global.ibgp.vpc.advertise_pip
           | default(defaults.vxlan.global.ibgp.vpc.advertise_pip)) %}
    Should Be Equal Value Json String   ${r.json()}   $..ADVERTISE_PIP_ON_BORDER   {{ vxlan.global.ibgp.vpc.advertise_pip_border_only | default(defaults.vxlan.global.ibgp.vpc.advertise_pip_border_only) | lower}}   msg=ADVERTISE_PIP_ON_BORDER
{% endif %}
    Should Be Equal Value Json String   ${r.json()}   $..VPC_DOMAIN_ID_RANGE   {{ vxlan.global.ibgp.vpc.domain_id_range | default(defaults.vxlan.global.ibgp.vpc.domain_id_range) }}     msg=VPC_DOMAIN_ID_RANGE
    Should Be Equal Value Json String   ${r.json()}   $..FABRIC_VPC_QOS   {{ (vxlan.global.ibgp.vpc.fabric_vpc_qos | default(defaults.vxlan.global.ibgp.vpc.fabric_vpc_qos) | lower) }}     msg=FABRIC_VPC_QOS
{% if (vxlan.global.ibgp.vpc.fabric_vpc_qos | default(defaults.vxlan.global.ibgp.vpc.fabric_vpc_qos)) %}
    Should Be Equal Value Json String   ${r.json()}   $..FABRIC_VPC_QOS_POLICY_NAME   {{ vxlan.global.ibgp.vpc.fabric_vpc_qos_policy_name | default(defaults.vxlan.global.ibgp.vpc.fabric_vpc_qos_policy_name) }}     msg=FABRIC_VPC_QOS_POLICY_NAME
{% endif %}

