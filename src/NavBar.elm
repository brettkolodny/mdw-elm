module NavBar exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg(..))


navBar : Model -> Html Msg
navBar model =
    let
        itemClass =
            "text-md text-gray-600 hover:text-black font-medium cursor-pointer transition-all"
    in
    div [ class "flex flex-col justify-start items-start gap-4 ml-20 mt-16" ]
        [ div [ class itemClass ] [ text "Accounts" ]
        , div [ class itemClass ] [ text "Send" ]
        , div [ class itemClass ] [ text "Stake" ]
        , div [ class itemClass ] [ text "Crowdloan" ]
        , div [ class itemClass ] [ text "Claim DOT" ]
        ]
