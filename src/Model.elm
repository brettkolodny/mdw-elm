module Model exposing (..)

import Routes.Overview.Model as Overview
import Session.Model as Session


type Route
    = AccountsRoute
    | SendRoute (Maybe String)
    | NotFoundRoute


type Page
    = Overview Overview.Model
    | Send


type alias Model =
    { session : Session.Model
    , route : Route
    , page : Page
    }
