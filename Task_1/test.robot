*** Settings ***
Library     SeleniumLibrary
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     BuiltIn
Library     decimal_helper.py
Library     number_formatter.py
Suite Teardown  Close Browser

*** Variables ***
${target_web_url}    https://www.bitopro.com/ns/fees

*** Keywords ***
Get Data
    #https://www.bitopro.com/ns-api/v3/provisioning/limitations-and-fees
    ${url}=     Set Variable    https://api.bitopro.com/v3/provisioning/limitations-and-fees
    ${response}=    GET  url=${url}
    ${readable_response}  Evaluate    json.dumps(${response.json()}, indent=4)    json
    Log     ${readable_response}
    RETURN      ${response.json()}

Go To Bito Limitations Page
    ${status}   ${current_url}=    Run Keyword And Ignore Error     Get Location
    ${contains}=    Run Keyword And Return Status   Should Contain  ${current_url}    ${target_web_url}
    IF  $status == "FAIL"
        Open Browser    https://www.bitopro.com/ns/fees     chrome
    ELSE IF     $status == "PASS" and ${contains} == False
        Go To    ${target_web_url}
    END

*** Test Cases ***
Go to Bito Limitations Page And Verify Tab
    Open Browser    ${target_web_url}     chrome
    Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="交易"]
    Element Should Be Visible    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]
    Element Should Be Visible    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]

Verify TradingFeeRate
    [Setup]     Go To Bito Limitations Page
    Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="交易"]
    Click Element   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="交易"]
    ${response_data_all}     Get Data
    ${tradingFeeRate_data}=     Set Variable    ${response_data_all['tradingFeeRate']}
    ${expect_ranks}=   Get length  ${tradingFeeRate_data}
    ${actual_ranks}=    	Get Element Count  xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"]
    Should Be Equal     ${expect_ranks}     ${actual_ranks}

    FOR     ${i}   IN RANGE    0   ${actual_ranks}
        ${fee_list}=    Set Variable    ${tradingFeeRate_data}[${i}]
        #Scroll Element Into View    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]
        ${vip_rank}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 gucxmN"][1]/span
        ${transaction_30d}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 hbzfNm"][1]/span
        ${rankCondition}=   Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 hmXTHO"]/span
        ${hold_1d}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 gucxmN"][2]/span
        ${maker_taker}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 hbzfNm"][2]/span
        ${maker_taker_80percentage}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 hbzfNm"][3]/span
        ${maker_taker_handling_fee}=    Get text    xpath=//div[@class="sc-8fd9cbbb-2 gxywJh"][${i}+1]/div[@class="sc-8fd9cbbb-1 hbzfNm"][4]/span
        Should Be Equal     ${vip_rank}     VIP ${fee_list['rank']}
        ${twdVolume}    Format Number With Commas  ${fee_list['twdVolume']}
        Should Be Equal     ${transaction_30d}  ${fee_list['twdVolumeSymbol']} ${twdVolume} TWD
        IF  "${fee_list['rankCondition']}"=="\u6216"
            Should Be Equal     "${rankCondition}"  "或"
        ELSE IF     "${fee_list['rankCondition']}"=="\u53ca"
            Should Be Equal     "${rankCondition}"  "及"
        END
        ${bitoAmount}    Format Number With Commas  ${fee_list['bitoAmount']}
        Should Be Equal     ${hold_1d}  ${fee_list['twdVolumeSymbol']} ${bitoAmount} BITO
        ${type string}=    Evaluate     type(${fee_list['makerFee']})
        ${makerFee}=    Convert Fee     ${${fee_list['makerFee']}}      #${fee_list['makerFee']}*100
        ${takerFee}=    Convert Fee     ${fee_list['takerFee']}     #${fee_list['takerFee']}*100
        Should Be Equal     ${maker_taker}  ${makerFee}% / ${takerFee}%
        ${makerBitoFee}=    Convert Fee     ${fee_list['makerBitoFee']}     #${fee_list['makerBitoFee']}*100
        ${takerBitoFee}=    Convert Fee     ${fee_list['takerBitoFee']}     #${fee_list['takerBitoFee']}*100
        Should Be Equal     ${maker_taker_80percentage}  ${makerBitoFee}% / ${takerBitoFee}%
        ${gridBotMakerFee}=    Convert Fee  ${fee_list['gridBotMakerFee']}      #${fee_list['gridBotMakerFee']}*100
        ${gridBotTakerFee}=    Convert Fee  ${fee_list['gridBotTakerFee']}      #${fee_list['gridBotTakerFee']}*100
        Should Be Equal     ${maker_taker_handling_fee}  ${gridBotMakerFee}% / ${gridBotTakerFee}%
    END

Verify Order Fees And Limitations
    [Setup]     Go To Bito Limitations Page
    Scroll Element Into View    xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="交易"]
    Click Element   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="交易"]
    ${response_data_all}     Get Data
    ${OrderFeesAndLimitations_data}=     Set Variable    ${response_data_all['orderFeesAndLimitations']}
    ${expect_limitations}=   Get length  ${OrderFeesAndLimitations_data}
    ${actual_limitations}=    	Get Element Count  xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')]
    Should Be Equal     ${expect_limitations}     ${actual_limitations}
    FOR     ${i}   IN RANGE    0   ${actual_limitations}
        ${index}=   Set Variable    ${0}
        #Scroll Element Into View    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i}+1]
        ${pair}=    Get text    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 dQbIlI"]
        FOR      ${j}   IN RANGE    0   ${actual_limitations}
            ${data}=    Set Variable    ${OrderFeesAndLimitations_data}[${j}]
            IF  $data['pair']==$pair
                ${index}=   Set Variable    ${j}
                Exit For Loop
            END
        END
        ${limitations_list}=    Set Variable    ${OrderFeesAndLimitations_data}[${index}]
        ${min_order_num}=    Get text    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 iHRFkz"]
        ${min_order_unit}=   Get text    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 hUwCHc"]
        Should Be Equal     ${pair}     ${limitations_list['pair']}
        ${minimumOrderAmount}    Format Number With Commas  ${limitations_list['minimumOrderAmount']}
        Should Be Equal     ${min_order_num}    ${minimumOrderAmount} ${limitations_list['minimumOrderAmountBase']}
        Should Be Equal     ${min_order_unit}   ${limitations_list['minimumOrderNumberOfDigits']}
    END

Verify Handing Fees Withdraw And Limitations
    [Setup]     Go To Bito Limitations Page
    ${select}   Run Keyword And Return Status   Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]    3s
    IF  $select==$False
        Scroll Element Into View    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]
        Click Element   xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]
    END
    ${response_data_all}     Get Data
    ${fWithdrawalFees_data}=     Set Variable    ${response_data_all['restrictionsOfWithdrawalFees']}
    ${expect}=   Get length  ${fWithdrawalFees_data}
    ${actual}=    	Get Element Count  xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')]
    Should Be Equal     ${expect}     ${actual}
    FOR     ${i}   IN RANGE    0   ${actual}
        ${index}=   Set Variable    ${0}
        #Scroll Element Into View    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i}+1]
        ${currency}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 bbRTKz"]
        FOR      ${j}   IN RANGE    0   ${actual}
            ${data}=    Set Variable    ${fWithdrawalFees_data}[${j}]
            IF  $data['currency']==$currency
                ${index}=   Set Variable    ${j}
                Exit For Loop
            END
        END
        ${list}=    Set Variable    ${fWithdrawalFees_data}[${index}]
        ${handing_fee}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 hyKpVu"]
        ${min_per_unit}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 bnEMbh"][1]
        ${max_per_unit}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 bnEMbh"][2]
        ${max_daily}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="提領手續費與限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 bnEMbh"][3]
        Should Be Equal     ${currency}     ${list['currency']}
        ${fee}    Format Number With Commas  ${list['fee']}
        Should Be Equal     ${handing_fee}    ${fee}
        ${minimumTradingAmount}    Format Number With Commas  ${list['minimumTradingAmount']}
        Should Be Equal     ${min_per_unit}    ${minimumTradingAmount}
        ${maximumTradingAmount}    Format Number With Commas  ${list['maximumTradingAmount']}
        Should Be Equal     ${max_per_unit}   ${maximumTradingAmount}
        ${dailyCumulativeMaximumAmount}    Format Number With Commas  ${list['dailyCumulativeMaximumAmount']}
        Should Be Equal     ${max_daily}   ${dailyCumulativeMaximumAmount}
    END

Verify Deposit Fee And Confirmation
    [Setup]     Go To Bito Limitations Page
    ${select}   Run Keyword And Return Status   Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]    3s
    IF  $select==$False
        Scroll Element Into View    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]
        Click Element   xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="加值 / 提領"]
    END
    ${response_data_all}     Get Data
    ${cryptocurrencyDepositFeeAndConfirmation}=     Set Variable    ${response_data_all['cryptocurrencyDepositFeeAndConfirmation']}
    ${expect}=   Get length  ${cryptocurrencyDepositFeeAndConfirmation}
    ${actual}=    	Get Element Count  xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="加值手續費與區塊確認數"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')]
    Should Be Equal     ${expect}     ${actual}
    FOR     ${i}   IN RANGE    0   ${actual}
        ${index}=   Set Variable    ${0}
        #Scroll Element Into View    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i}+1]
        ${currency}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="加值手續費與區塊確認數"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 dQbIlI"]
        FOR      ${j}   IN RANGE    0   ${actual}
            ${data}=    Set Variable    ${cryptocurrencyDepositFeeAndConfirmation}[${j}]
            IF  $data['currency']==$currency
                ${index}=   Set Variable    ${j}
                Exit For Loop
            END
        END
        ${list}=    Set Variable    ${cryptocurrencyDepositFeeAndConfirmation}[${index}]
        ${handing_fee}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="加值手續費與區塊確認數"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 gQshZP"]
        ${blockchainConfirmation}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="加值手續費與區塊確認數"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 OqeIl"]
        IF  '${list['generalDepositFees']}'=='0'
            Should Be Equal     "${handing_fee}"    "免費"
        ELSE
            ${generalDepositFees}    Format Number With Commas  ${list['generalDepositFees']}
            Should Be Equal     ${handing_fee}    ${generalDepositFees}
        END
        ${blockchainConfirmationRequired}    Format Number With Commas  ${list['blockchainConfirmationRequired']}
        Should Be Equal     ${blockchainConfirmation}    ${blockchainConfirmationRequired}
    END

Verify TTCheck Gift Card Limitations Level1
    [Setup]     Go To Bito Limitations Page
    ${select}   Run Keyword And Return Status   Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]    3s
    IF  $select==$False
        Scroll Element Into View    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]
        Click Element   xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]
    END
    ${response_data_all}     Get Data
    ${ttCheckFeesAndLimitationsLevel1}=     Set Variable    ${response_data_all['ttCheckFeesAndLimitationsLevel1']}
    ${first_data}=  Set Variable    ${ttCheckFeesAndLimitationsLevel1}[0]
    IF  "${first_data['redeemDailyCumulativeMaximumAmount']}"==""
        Element Should Be Visible   //div[@class="sc-ae3accfd-0 cawphk" and text()="* Level 1 不支援使用 TTCheck 禮物卡服務，請升級至 Level 2"]
    ELSE
        ${expect}=   Get length  ${ttCheckFeesAndLimitationsLevel1}
        ${actual}=    	Get Element Count  xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 1 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')]
        Should Be Equal     ${expect}     ${actual}
    END
    
Verify TTCheck Gift Card Limitations Level2
    [Setup]     Go To Bito Limitations Page
    ${select}   Run Keyword And Return Status   Wait Until Element Is Visible   xpath=//div[@class="sc-ae3accfd-0 fbIpIP sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]    3s
    IF  $select==$False
        Scroll Element Into View    xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]
        Click Element   xpath=//div[@class="sc-ae3accfd-0 jayFXU sc-4003a7c5-0 cTSyqs" and text()="TTCheck 禮物卡"]
    END
    ${response_data_all}     Get Data
    ${ttCheckFeesAndLimitationsLevel2}=     Set Variable    ${response_data_all['ttCheckFeesAndLimitationsLevel2']}
    ${first_data}=  Set Variable    ${ttCheckFeesAndLimitationsLevel2}[0]
    IF  "${first_data['redeemDailyCumulativeMaximumAmount']}"==""
        Element Should Be Visible   //div[@class="sc-ae3accfd-0 cawphk" and text()="* Level 2 不支援使用 TTCheck 禮物卡服務，請升級至 Level 3"]
    ELSE
        ${expect}=   Get length  ${ttCheckFeesAndLimitationsLevel2}
        ${actual}=    	Get Element Count  xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')]
        Should Be Equal     ${expect}     ${actual}
        FOR     ${i}   IN RANGE    0   ${actual}
            ${index}=   Set Variable    ${0}
            #Scroll Element Into View    xpath=//tr[contains(@class, 'sc-ae3accfd-0 ')][${i}+1]
            ${currency}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 ehHDIg"]
            FOR      ${j}   IN RANGE    0   ${actual}
                ${data}=    Set Variable    ${ttCheckFeesAndLimitationsLevel2}[${j}]
                IF  $data['currency']==$currency
                    ${index}=   Set Variable    ${j}
                    Exit For Loop
                END
            END
            ${list}=    Set Variable    ${ttCheckFeesAndLimitationsLevel2}[${index}]
            ${daliy_max_redeem}=    Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 edDSVM"][1]
            ${min_per_order}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 edDSVM"][2]
            ${max_per_order}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 edDSVM"][3]
            ${daliy_max_gen}=   Get text    xpath=//h4[@class="sc-e19ca049-0 gVjCVD" and text()="Level 2 額度限制"]/../div//tr[contains(@class, 'sc-ae3accfd-0 ')][${i+1}]/td[@class="sc-ae3accfd-0 edDSVM"][4]
            ${redeemDailyCumulativeMaximumAmount}    Format Number With Commas  ${list['redeemDailyCumulativeMaximumAmount']}
            Should Be Equal     ${daliy_max_redeem}    ${redeemDailyCumulativeMaximumAmount}
            ${generateMinimumTradingAmount}    Format Number With Commas  ${list['generateMinimumTradingAmount']}
            Should Be Equal     ${min_per_order}    ${generateMinimumTradingAmount}
            ${generateMaximumTradingAmount}    Format Number With Commas  ${list['generateMaximumTradingAmount']}
            Should Be Equal     ${max_per_order}    ${generateMaximumTradingAmount}
            ${generateDailyCumulativeMaximumAmount}    Format Number With Commas  ${list['generateDailyCumulativeMaximumAmount']}
            Should Be Equal     ${daliy_max_gen}    ${generateDailyCumulativeMaximumAmount}
        END
    END