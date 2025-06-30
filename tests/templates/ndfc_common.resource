# This is a simplified version file for demonstration purposes.

*** Settings ***
Library   pabot.PabotLib
Library   RequestsLibrary
Library   JSONLibrary
Library   Collections
Library   OperatingSystem

*** Variables ***
${login_json}   {"domain" : "%{ND_DOMAIN=local}", "userName" : "%{ND_USERNAME}", "userPasswd" : "%{ND_PASSWORD}"}

*** Keywords ***
Get ND Token
    Create Session   login   https://%{ND_HOST}
    ${log_level}=   Set Log Level   TRACE
    ${response}=   Wait Until Keyword Succeeds   6x   10s   POST On Session   login   /login   data=${login_json}
    Set Log Level   ${log_level}
    ${r_token}=   Get Value From Json   ${response.json()}   $..jwttoken
    Set Parallel Value For Key   nd_token   ${r_token[0]}

Login NDFC
    Run Only Once   Get ND Token
    ${nd_token}=   Get Parallel Value For Key   nd_token
    Create Session   ndfc   https://%{ND_HOST}   headers={"Cookie": "AuthCookie=${nd_token}", "Accept": "*/*"}

Should Be Equal Value Json String
   [Arguments]   ${json}    ${json_path}   ${value}=${EMPTY}  ${msg}=${EMPTY}
   ${r_value}=   Get Value From Json   ${json}   ${json_path}
   ${r_value}=   Set Variable If    ${r_value} == []    not_defined    ${r_value[0]}
   Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Strings    ${r_value}    ${value}    msg=${msg}


