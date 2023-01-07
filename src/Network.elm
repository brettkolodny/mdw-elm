module Network exposing (..)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))
import Session.Model exposing (Network(..), NetworkState)
import Session.Update as Session
import VitePluginHelper


networkSelect : NetworkState -> Html Msg
networkSelect networkState =
    let
        ( currentNetworkImage, currentNetworkText ) =
            case networkState.currentNetwork of
                Kusama ->
                    ( img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/kusama-network.png" ] []
                    , "Kusama"
                    )

                Polkadot ->
                    ( img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/polkadot-network.png" ] []
                    , "Polkadot"
                    )

        ( otherNetworkImage, otherNetworkText, otherNetwork ) =
            case networkState.currentNetwork of
                Kusama ->
                    ( img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/polkadot-network.png" ] []
                    , "Polkadot"
                    , Polkadot
                    )

                Polkadot ->
                    ( img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/kusama-network.png" ] []
                    , "Kusama"
                    , Kusama
                    )
    in
    div [ class "flex" ]
        [ div
            [ class "relative flex flex-row justify-start items-center gap-2 border w-40 pl-4 p-2 rounded-full text-sm font-bold cursor-pointer"
            , onClick (SessionMsg Session.ToggleShowNetworks)
            ]
            [ currentNetworkImage
            , text currentNetworkText
            ]
        , if networkState.showNetworks then
            div [ class "absolute flex flex-col divide-y bg-white border rounded-[26px] shadow-lg" ]
                [ div
                    [ class "flex flex-row justify-start items-center gap-2 w-40 pl-4 p-2 text-sm font-bold cursor-pointer"
                    , onClick (SessionMsg Session.ToggleShowNetworks)
                    ]
                    [ currentNetworkImage
                    , text currentNetworkText
                    ]
                , div
                    [ class "flex flex-row justify-start items-center gap-2 w-40 pl-4 p-2 text-sm font-bold cursor-pointer"
                    , onClick (SessionMsg (Session.SwitchNetwork otherNetwork))
                    ]
                    [ otherNetworkImage
                    , text otherNetworkText
                    ]
                ]

          else
            div [] []
        ]
