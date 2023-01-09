module Msg exposing (Msg(..))

import Http
import Routes.Overview.Update as Overview
import Routes.Send.Update as Send
import Session.Model exposing (Prices)
import Session.Update as Session
import Model exposing (Page)


type Msg
    = GotPrices (Result Http.Error Prices)
    | SessionMsg Session.Msg
    | OverviewMsg Overview.Msg
    | SendMsg Send.Msg
    | ChangePage Page
