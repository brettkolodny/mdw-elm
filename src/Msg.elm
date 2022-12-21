module Msg exposing (Msg(..))

import Http
import Routes.Overview.Update as Overview
import Session.Model exposing (Account, Network, Prices)
import Session.Update as Session


type Msg
    = GotPrices (Result Http.Error Prices)
    | ConnectExtension String
    | SwitchNetwork Network
    | UpdateAccounts (List Account)
    | SessionMsg Session.Msg
    | OverviewMsg Overview.Msg
