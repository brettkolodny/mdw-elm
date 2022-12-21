module Model exposing (..)

import Session.Model as SessionModel


type Route
    = AccountsRoute
    | SendRoute (Maybe String)
    | NotFoundRoute


type alias Model =
    { session : SessionModel.Model
    , route : Route
    }
