module Model exposing (..)

import Browser.Navigation
import Routes.Overview.Model as Overview
import Routes.Send.Model as Send
import Session.Model as Session
import Url exposing (Url)


type Route
    = AccountsRoute
    | SendRoute (Maybe String)
    | NotFoundRoute


type Page
    = Overview Overview.Model
    | Send Send.Model


type alias Model =
    { session : Session.Model
    , route : Route
    , page : Page
    , key : Browser.Navigation.Key
    , url : Url
    }
