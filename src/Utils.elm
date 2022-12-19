module Utils exposing (..)

import Html exposing (Html, node)
import Html.Attributes exposing (attribute)
import Msg exposing (Msg)
import Round


formatAddress : String -> String
formatAddress address =
    let
        stringLength =
            String.length address
    in
    String.concat [ String.slice 0 6 address, "...", String.slice (stringLength - 6) stringLength address ]


formatTokenAmount : Int -> Int -> String
formatTokenAmount amount decimals =
    if amount == 0 then
        "0.0"

    else
        Round.round 3 (toFloat amount / (10.0 ^ toFloat decimals))


formatTokenPrice : Int -> Int -> Maybe Float -> String
formatTokenPrice amount decimals price =
    case price of
        Just p ->
            "$" ++ Round.round 2 (toFloat amount / (10.0 ^ toFloat decimals) * p)

        Nothing ->
            "~"


addressElement : Bool -> String -> String -> Html Msg
addressElement cutOff network address =
    let
        cutOffString =
            if cutOff then
                "true"

            else
                "false"
    in
    node "wallet-address"
        [ attribute "cut-off" cutOffString
        , attribute "network" network
        , attribute "address" address
        ]
        []


addressCutOffElement : String -> String -> Html Msg
addressCutOffElement network address =
    addressElement True network address


identicon : String -> Html Msg
identicon address =
    node "address-identicon" [ attribute "address" address ] []
