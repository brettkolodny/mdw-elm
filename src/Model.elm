module Model exposing (..)

import Session.Model as Session


type Route
    = AccountsRoute
    | SendRoute (Maybe String)
    | NotFoundRoute


type alias Model =
    { session : Session.Model
    , route : Route
    }
