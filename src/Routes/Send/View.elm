module Routes.Send.View exposing (..)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, src)
import Msg exposing (Msg(..))
import Session.Model as Session


send : Session.Model -> Html Msg
send session =
    div [] [ text "hello" ]
