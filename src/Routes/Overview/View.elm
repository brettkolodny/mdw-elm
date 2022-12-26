module Routes.Overview.View exposing (..)

import EnkryptBanner exposing (enkryptBanner)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))
import Routes.Overview.Model exposing (Model)
import Routes.Overview.Update as Overview
import Session.Model as Session exposing (Account, Network(..))
import Utils exposing (addressCutOffElement, formatTokenAmount, formatTokenPrice, identicon)
import VitePluginHelper


accounts : Session.Model -> Model -> Html Msg
accounts session model =
    let
        accs =
            session.accounts

        network =
            session.network.currentNetwork

        price =
            Maybe.map
                (\p ->
                    case network of
                        Polkadot ->
                            p.polkadot.usd

                        Kusama ->
                            p.kusama.usd
                )
                session.prices

        ( tokenSymbol, decimals ) =
            case network of
                Polkadot ->
                    ( "DOT", 10 )

                Kusama ->
                    ( "KSM", 12 )

        totalBalance =
            List.map
                (\a ->
                    case a.balance of
                        Just b ->
                            b.available + b.staked

                        Nothing ->
                            0
                )
                accs
                |> List.foldl (+) 0

        totalBalanceFormat =
            if totalBalance == 0 then
                "0.0"

            else
                formatTokenAmount totalBalance decimals
    in
    div [ class "w-full flex flex-col justify-center items-center mt-20 gap-4" ]
        [ enkryptBanner session
        , div [ class "flex flex-col justify-center items-center w-full max-w-4xl bg-white p-4 rounded-xl shadow-lg" ]
            [ div [ class "flex flex-row justify-between items-center w-full px-4 mb-8" ]
                [ div [ class "flex flex-col justify-center items-start" ]
                    [ div [ class "text-sm text-gray-600" ] [ text "Total Balance" ]
                    , div [ class "text-2xl font-bold" ] [ text (totalBalanceFormat ++ " " ++ tokenSymbol) ]
                    , div [ class "text-gray-500" ] [ text (formatTokenPrice totalBalance decimals price) ]
                    ]
                , div [ class "flex flex-row gap-4" ]
                    [ div [ class "px-4 py-1 text-gray-500 border rounded-lg cursor-pointer" ] [ text "Stake" ]
                    , div [ class "px-4 py-1 text-gray-500 border rounded-lg cursor-pointer" ] [ text "Send" ]
                    ]
                ]
            , div [ class "flex flex-col w-full gap-2" ] (List.map (accountItem network price model) accs)
            ]
        ]


accountItem : Network -> Maybe Float -> Model -> Account -> Html Msg
accountItem network price model account =
    let
        showAccount =
            List.member account.address model

        ( netString, tokenSymbol, decimals ) =
            case network of
                Polkadot ->
                    ( "Polkadot", "DOT", 10 )

                Kusama ->
                    ( "Kusama", "KSM", 12 )

        totalBalance =
            case account.balance of
                Just balance ->
                    formatTokenAmount (balance.available + balance.staked) decimals

                Nothing ->
                    "~"
    in
    div []
        [ div
            [ class "flex flex-row justify-between items-center w-full px-4 py-2 hover:bg-gray-100 cursor-pointer rounded-md"
            , onClick (OverviewMsg (Overview.ToggleShow account.address))
            ]
            [ div [ class "flex flex-row justify-center items-center gap-4" ]
                [ identicon account.address
                , div [ class "flex flex-col justify-center items-start" ]
                    [ div [ class "text-black font-medium" ] [ text account.name ]
                    , div [ class "text-sm" ] [ addressCutOffElement netString account.address ]
                    ]
                ]
            , div [ class "flex flex-row gap-8" ]
                [ div [ class "text-black text-xl font-bold" ] [ text (totalBalance ++ " " ++ tokenSymbol) ]
                , div []
                    [ if showAccount then
                        img [ class "w-8 h-8 transform rotate-180 transition-all", src <| VitePluginHelper.asset "/src/assets/icons/chevron.svg" ] []

                      else
                        img [ class "w-8 h-8 transition-all", src <| VitePluginHelper.asset "/src/assets/icons/chevron.svg" ] []
                    ]
                ]
            ]
        , if showAccount then
            div [ class "w-full" ] [ accountExpanded account network price, div [ class "w-full h-px bg-gray-300" ] [] ]

          else
            div [] []
        ]


accountExpanded : Account -> Network -> Maybe Float -> Html Msg
accountExpanded account network price =
    let
        ( tokenSymbol, decimals ) =
            case network of
                Polkadot ->
                    ( "DOT", 10 )

                Kusama ->
                    ( "KSM", 12 )

        defaultBalance =
            { available = 0, staked = 0 }
    in
    div [ class "flex flex-col justify-center items-start gap-4 w-full my-4 pl-12" ]
        [ div [ class "grid grid-cols-4 grid-rows-1 w-full" ]
            [ div [ class "flex flex-row items-start" ] [ text "Available" ]
            , div [ class "flex flex-row items-start" ] [ text (formatTokenPrice (Maybe.withDefault defaultBalance account.balance).available decimals price) ]
            , div [ class "flex flex-row items-start" ] [ text (formatTokenAmount (Maybe.withDefault defaultBalance account.balance).available decimals ++ " " ++ tokenSymbol) ]
            , div [ class "flex flex-row gap-2" ]
                [ div [ class "px-4 py-1 text-gray-500 border rounded-lg cursor-pointer" ] [ text "Stake" ]
                , div [ class "px-4 py-1 text-gray-500 border rounded-lg cursor-pointer" ] [ text "Send" ]
                ]
            ]
        , div [ class "grid grid-cols-4 grid-rows-1 w-full" ]
            [ div [ class "flex flex-row items-start" ] [ text "Staked" ]
            , div [ class "flex flex-row items-start" ] [ text (formatTokenPrice (Maybe.withDefault defaultBalance account.balance).staked decimals price) ]
            , div [ class "flex flex-row items-start" ] [ text (formatTokenAmount (Maybe.withDefault defaultBalance account.balance).staked decimals ++ " " ++ tokenSymbol) ]
            ]
        ]
