module NavBar exposing (..)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Model exposing (Model, Page(..))
import Msg exposing (Msg(..))
import Routes.Overview.Model as OverviewModel


navBar : Model -> Html Msg
navBar _ =
    let
        itemClass =
            "text-md text-gray-600 hover:text-black font-medium cursor-pointer transition-all"
    in
    div [ class "flex flex-col justify-start items-start gap-4 ml-20 mt-16" ]
        [ a [ href "/", class itemClass, onClick (ChangePage (Overview OverviewModel.model)) ] [ text "Accounts" ]
        , a [ href "/send", class itemClass ] [ text "Send" ]
        , div [ class itemClass ] [ text "Stake" ]
        , div [ class itemClass ] [ text "Crowdloan" ]
        , div [ class itemClass ] [ text "Claim DOT" ]
        ]
