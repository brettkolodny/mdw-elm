module Routes.Send.View exposing (..)

import EnkryptBanner exposing (enkryptBanner)
import Html exposing (Html, button, div, h1, h2, img, input, span, text)
import Html.Attributes exposing (alt, class, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Msg exposing (Msg(..))
import Round
import Routes.Send.Model as Send
import Routes.Send.Update as SendMsg
import Session.Model as Session exposing (Network(..))
import Success exposing (success)
import Utils
import VitePluginHelper


type FieldFor
    = From
    | To


send : Session.Model -> Send.Model -> Html Msg
send session model =
    let
        path =
            case model.fromAccount of
                Just account ->
                    "/send/?q=" ++ account.address

                _ ->
                    "/send"
    in
    if model.confirmed then
        success path

    else
        div [ class "w-full flex flex-col justify-center items-center mt-12 gap-4" ]
            [ enkryptBanner session
            , if model.verifyTransaction then
                verifyTransaction session model

              else
                div [ class "flex flex-col justify-center items-center gap-4 w-full max-w-4xl bg-white p-4 rounded-xl shadow-lg" ]
                    [ h1 [ class "self-start text-4xl text-[#333] font-bold" ] [ text "Send" ]
                    , fromAddressField session model
                    , toAddressField session model
                    , sendAmountField session model
                    , transactionPreview session model
                    , continueButton session model
                    ]
            ]


fromAddressField : Session.Model -> Send.Model -> Html Msg
fromAddressField session model =
    let
        ( tokenSymbol, decimals ) =
            case session.network.currentNetwork of
                Session.Polkadot ->
                    ( "DOT", 10 )

                _ ->
                    ( "KSM", 12 )

        fromAddressValid =
            case model.fromAccount of
                Just account ->
                    Utils.addressIsValid account.address

                _ ->
                    False

        ( fromName, fromAddress, balance ) =
            case model.fromAccount of
                Just account ->
                    let
                        accountBalance =
                            case account.balance of
                                Just b ->
                                    Utils.formatTokenAmount b.available decimals

                                _ ->
                                    "~"
                    in
                    ( account.name, account.address, accountBalance )

                _ ->
                    ( "", "", "" )

        fromAddressIdenticon =
            if fromAddressValid then
                div [ class "flex justify-center items-center rounded-full px-4" ]
                    [ Utils.identicon fromAddress ]

            else
                div [ class "w-8 h-8 bg-gray-200 rounded-full px-4 mx-3" ] []
    in
    div [ class "w-full" ]
        [ div [ class "flex flex-row justify-center items-center h-16 border rounded-xl" ]
            [ fromAddressIdenticon
            , div
                [ class "flex flex-col justify-center items-start w-full h-16"
                , onClick (SendMsg SendMsg.ToggleFromAddressSelection)
                ]
                [ div [ class "text-sm" ] [ text "From" ]
                , div []
                    [ div []
                        [ case model.fromAccount of
                            Just _ ->
                                div [ class "flex flex-row gap-2" ]
                                    [ span [ class "font-medium" ] [ text fromName ]
                                    , span [ class "text-gray-500" ] [ text (Utils.formatAddress fromAddress) ]
                                    , span [ class "flex flex-row gap-1 text-gray-500" ]
                                        [ span [ class "" ] [ text balance ], span [] [ text tokenSymbol ] ]
                                    ]

                            _ ->
                                text "Select an account to send from"
                        ]
                    ]
                ]
            ]
        , div [ class "relative w-full" ]
            [ if model.showFromAddressSelection then
                addressDropDown session model From

              else
                div [] []
            ]
        ]


toAddressField : Session.Model -> Send.Model -> Html Msg
toAddressField session model =
    let
        toAddressValid =
            Utils.addressIsValid model.toAddress

        toAddressIdenticon =
            if toAddressValid then
                div [ class "flex justify-center items-center rounded-full px-4" ] [ Utils.identicon model.toAddress ]

            else
                div [ class "w-8 h-8 bg-gray-200 rounded-full px-4 mx-3" ] []

        inputCss =
            if not toAddressValid then
                "text-red"

            else
                ""
    in
    div [ class "w-full" ]
        [ div [ class "flex flex-row justify-center items-center h-16 border rounded-xl" ]
            [ toAddressIdenticon
            , div [ class "flex flex-col justify-center items-start w-full h-16" ]
                [ div [ class "text-sm" ] [ text "To" ]
                , input
                    [ class ("w-full focus:outline-none " ++ inputCss)
                    , type_ "text"
                    , placeholder "Search or paste Polkadot address"
                    , value model.toAddress
                    , onInput (SendMsg.ToAddressUpdated >> SendMsg)
                    , onClick (SendMsg SendMsg.ToggleToAddressSelection)
                    ]
                    []
                ]
            ]
        , div [ class "absolute w-[754px]" ]
            [ if model.showToAddressSelection then
                addressDropDown session model To

              else
                div [] []
            ]
        ]


sendAmountField : Session.Model -> Send.Model -> Html Msg
sendAmountField session model =
    let
        ( tokenSymbol, decimals, icon ) =
            case session.network.currentNetwork of
                Session.Polkadot ->
                    ( "DOT", 10, VitePluginHelper.asset "/src/assets/polkadot-network.png" )

                _ ->
                    ( "KSM", 12, VitePluginHelper.asset "/src/assets/kusama-network.png" )

        tokenPrice =
            case session.prices of
                Just prices ->
                    if tokenSymbol == "DOT" then
                        prices.polkadot.usd

                    else
                        prices.kusama.usd

                _ ->
                    0.0

        sendAmountValid =
            case model.sendAmount of
                Just _ ->
                    True

                _ ->
                    False

        isOvermax =
            case model.fromAccount of
                Just account ->
                    case account.balance of
                        Just balance ->
                            Utils.fromBase balance.available decimals < Maybe.withDefault 0 model.sendAmount

                        Nothing ->
                            False

                Nothing ->
                    False

        sendCss =
            if not sendAmountValid || isOvermax then
                "text-red-400"

            else
                ""

        sendPrice =
            case model.sendAmount of
                Just amount ->
                    Round.floor 2 (amount * tokenPrice)

                _ ->
                    "0.00"
    in
    div [ class "w-full" ]
        [ div [ class "flex flex-col gap-2 w-full rounded-lg border border-gray-200 py-2" ]
            [ div [ class "flex flex-row justefiy-between gap-4 items-center" ]
                [ img [ class "w-8 h-8 ml-3", src <| icon ] []
                , input
                    [ class ("w-full text-4xl focus:outline-none " ++ sendCss)
                    , placeholder "0"
                    , onInput (\str -> SendMsg (SendMsg.SendAmountUpdated str session.network.currentNetwork))
                    ]
                    []
                , div [ class "text-4xl pr-4" ] [ text tokenSymbol ]
                ]
            , div [ class "flex flex-row justify-start pl-14 text-gray-400" ] [ text ("~$" ++ sendPrice) ]
            ]
        ]


addressDropDown : Session.Model -> Send.Model -> FieldFor -> Html Msg
addressDropDown session _ for =
    let
        ( tokenSymbol, decimals ) =
            case session.network.currentNetwork of
                Session.Polkadot ->
                    ( "DOT", 10 )

                _ ->
                    ( "KSM", 12 )

        availableBalance account =
            case account.balance of
                Just b ->
                    b.available

                _ ->
                    0

        clickMsg address =
            case for of
                From ->
                    SendMsg.FromAddressSelected address

                To ->
                    SendMsg.ToAddressSelected address.address

        addressElement account =
            div
                [ class "flex flex-row justify-start items-center gap-4 w-full px-1 py-2 hover:bg-gray-200 rounded-lg transition-all cursor-pointer"
                , onClick (SendMsg (clickMsg account))
                ]
                [ Utils.identicon account.address
                , div [ class "text-md font-bold" ] [ text account.name ]
                , div [ class "text-sm text-gray-400" ] [ text (Utils.formatAddress account.address) ]
                , div [] [ text (Utils.formatTokenAmount (availableBalance account) decimals ++ tokenSymbol) ]
                ]
    in
    div [ class "absolute flex flex-col justify-center items-start p-4 bg-white shadow-md rounded-xl border border-gray-100" ]
        [ div [] [ text "My accounts" ]
        , div
            [ class "flex flex-col justify-center items-start w-full" ]
            (List.map
                addressElement
                session.accounts
            )
        ]


transactionPreview : Session.Model -> Send.Model -> Html Msg
transactionPreview session model =
    let
        ( decimals, tokenSymbol ) =
            case session.network.currentNetwork of
                Polkadot ->
                    ( 10, "DOT" )

                Kusama ->
                    ( 12, "KSM" )

        tokenPrice =
            case session.prices of
                Just prices ->
                    if tokenSymbol == "DOT" then
                        prices.polkadot.usd

                    else
                        prices.kusama.usd

                _ ->
                    0.0
    in
    div [ class "flex flex-row gap-4 self-start text-sm text-gray-500 font-medium" ]
        [ div [] [ text "Network fee:" ]
        , div [] [ text ("~" ++ Utils.formatTokenPrice model.transactionPreview decimals (Just tokenPrice)) ]
        , div [ class "text-gray-400" ] [ text (Utils.formatTokenAmount model.transactionPreview decimals ++ " " ++ tokenSymbol) ]
        ]


continueButton : Session.Model -> Send.Model -> Html Msg
continueButton session model =
    let
        decimals =
            case session.network.currentNetwork of
                Polkadot ->
                    10

                Kusama ->
                    12

        fromAccountSelected =
            case model.fromAccount of
                Just _ ->
                    True

                Nothing ->
                    False

        toAddressValid =
            Utils.addressIsValid model.toAddress

        sendAmountValid =
            case model.sendAmount of
                Just _ ->
                    True

                _ ->
                    False

        isOvermax =
            case model.fromAccount of
                Just account ->
                    case account.balance of
                        Just balance ->
                            Utils.fromBase balance.available decimals < Maybe.withDefault 0 model.sendAmount

                        Nothing ->
                            False

                Nothing ->
                    False
    in
    if fromAccountSelected && toAddressValid && sendAmountValid && not isOvermax then
        div [ class "flex justify-center items-center w-full", onClick (SendMsg SendMsg.ToggleVerifyTransaction) ]
            [ button [ class "w-48 h-12 text-lg font-medium bg-[#e6007a] text-white rounded-full" ]
                [ text "Continue" ]
            ]

    else
        div [ class "flex justify-center items-center w-full" ]
            [ button [ class "w-48 h-12 text-lg font-medium bg-gray-300 text-gray-400 rounded-full cursor-not-allowed" ]
                [ text "Continue" ]
            ]


verifyTransaction : Session.Model -> Send.Model -> Html Msg
verifyTransaction session model =
    let
        ( fromAddress, fromAccountName ) =
            case model.fromAccount of
                Just account ->
                    ( account.address, account.name )

                _ ->
                    ( "EfeYy93gzg9EN4HEEMvHg9yY7rpc9sTrjqnt1cbkfQAyHeD", "Name" )

        ( tokenSymbol, _, networkIcon ) =
            case session.network.currentNetwork of
                Session.Polkadot ->
                    ( "DOT", 10, VitePluginHelper.asset "/src/assets/polkadot-network.png" )

                _ ->
                    ( "KSM", 12, VitePluginHelper.asset "/src/assets/kusama-network.png" )

        sendPrice =
            case model.sendAmount of
                Just amount ->
                    Round.floor 2 (amount * tokenPrice)

                _ ->
                    "0.00"

        tokenPrice =
            case session.prices of
                Just prices ->
                    if tokenSymbol == "DOT" then
                        prices.polkadot.usd

                    else
                        prices.kusama.usd

                _ ->
                    0.0
    in
    div [ class "flex flex-col justify-center items-center gap-4 w-full max-w-4xl bg-white p-4 rounded-xl shadow-lg" ]
        [ div [ class "flex flex-row justify-start gap-6 w-full" ]
            [ div
                [ onClick (SendMsg SendMsg.ToggleVerifyTransaction)
                , class "flex justify-center items-center w-8 h-8 rounded-lg cursor-pointer hover:bg-gray-200 transition-all"
                ]
                [ img
                    [ class "self-start pt-1"
                    , alt "back"
                    , src <| VitePluginHelper.asset "/src/assets/icons/left-arrow.svg"
                    ]
                    []
                ]
            , div [ class "flex flex-col gap-4" ]
                [ h1 [ class "self-start text-2xl text-[#333] font-bold" ] [ text "Verify transaction" ]
                , h2 [ class "text-gray-500" ] [ text "Double check the information and confirm transaction." ]
                ]
            ]
        , div [ class "w-full bg-gray-50 rounded-md divide-y" ]
            [ div [ class "flex flex-row items-center gap-4 pl-4 py-4" ]
                [ Utils.identicon fromAddress
                , div [ class "flex flex-col items-start" ]
                    [ div [ class "text-sm float-left" ] [ text "From" ]
                    , div [ class "flex flex-row gap-2" ]
                        [ div [ class "font-medium" ] [ text fromAccountName ]
                        , div [ class "text-gray-400" ] [ text (Utils.formatAddress fromAddress) ]
                        ]
                    ]
                ]
            , div [ class "flex flex-row items-center gap-4 pl-4 py-4" ]
                [ Utils.identicon model.toAddress
                , div [ class "flex flex-col items-start" ]
                    [ div [ class "text-sm float-left" ] [ text "To" ]
                    , div [ class "flex flex-row gap-2" ]
                        [ div [ class "font-medium" ] [ text model.toAddress ]
                        ]
                    ]
                ]
            , div [ class "pl-4 py-4" ]
                [ div [ class "flex flex-row items-center gap-4" ]
                    [ img [ src <| networkIcon, class "w-8 h-8" ] []
                    , div [ class "flex flex-col" ]
                        [ div [ class "flex flex-row gap-2 " ]
                            [ span [ class "text-4xl font-medium" ]
                                [ text (String.fromFloat (Maybe.withDefault 0.0 model.sendAmount)) ]
                            , span [ class "text-2xl font-medium self-end" ] [ text tokenSymbol ]
                            ]
                        , div [ class "self-start text-sm text-gray-500" ] [ text ("~$" ++ sendPrice) ]
                        ]
                    ]
                ]
            , div [ class "pl-4 py-2" ] [ transactionPreview session model ]
            ]
        , div [ class "flex justify-center items-center w-full", onClick (SendMsg (SendMsg.SendTokens session.network.currentNetwork)) ]
            [ button [ class "w-48 h-12 text-lg font-medium bg-[#e6007a] text-white rounded-full" ]
                [ if model.confirming then
                    div [ class "flex justify-center items-center w-full" ]
                        [ img
                            [ class "w-8 h-8 animate-spin"
                            , src <| VitePluginHelper.asset "/src/assets/icons/loading.svg"
                            ]
                            []
                        ]

                  else
                    text "Confirm and send"
                ]
            ]
        ]
