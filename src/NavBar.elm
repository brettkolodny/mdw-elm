module NavBar exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model, Page(..))
import Msg exposing (Msg(..))
import Routes.Overview.Model as OverviewModel
import Routes.Send.Model as SendModel


navBar : Model -> Html Msg
navBar _ =
    let
        itemClass =
            "text-md text-gray-600 hover:text-black font-medium cursor-pointer transition-all"
    in
    div [ class "flex flex-col justify-start items-start gap-4 ml-20 mt-16" ]
        [ div [ class itemClass, onClick (ChangePage (Overview OverviewModel.model)) ] [ text "Accounts" ]
        , div [ class itemClass, onClick (ChangePage (Send SendModel.model)) ] [ text "Send" ]
        , div [ class itemClass ] [ text "Stake" ]
        , div [ class itemClass ] [ text "Crowdloan" ]
        , div [ class itemClass ] [ text "Claim DOT" ]
        ]
