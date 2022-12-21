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
                    ( img [ class "w-8 h-8", src <| VitePluginHelper.asset "/src/assets/kusama-network.png" ] []
                    , "Kusama"
                    )

                Polkadot ->
                    ( img [ class "w-8 h-8", src <| VitePluginHelper.asset "/src/assets/polkadot-network.png" ] []
                    , "Polkadot"
                    )

        --
        --    div [ class "flex flex-row justify-start items-center w-8 h-8", onClick ToggleShowNetworks ]
        --        [ img [ src <| VitePluginHelper.asset "/src/assets/polkadot-network.png" ] []
        --        , text "Polkadot"
        --        ]
        ( otherNetworkImage, otherNetworkText, otherNetwork ) =
            case networkState.currentNetwork of
                Kusama ->
                    ( img [ class "w-8 h-8", src <| VitePluginHelper.asset "/src/assets/polkadot-network.png" ] []
                    , "Polkadot"
                    , Polkadot
                    )

                Polkadot ->
                    ( img [ class "w-8 h-8", src <| VitePluginHelper.asset "/src/assets/kusama-network.png" ] []
                    , "Kusama"
                    , Kusama
                    )
    in
    div []
        [ div
            [ class "flex flex-row justify-start items-center gap-4 border w-48 pl-4 p-2 rounded-full text-xl font-bold cursor-pointer"
            , onClick (SessionMsg Session.ToggleShowNetworks)
            ]
            [ currentNetworkImage
            , text currentNetworkText
            ]
        , if networkState.showNetworks then
            div
                [ class "absolute flex flex-row justify-start items-center gap-4 border w-48 pl-4 p-2 rounded-full text-xl font-bold mt-2 cursor-pointer"
                , onClick (SwitchNetwork otherNetwork)
                ]
                [ otherNetworkImage
                , text otherNetworkText
                ]

          else
            div [] []
        ]
