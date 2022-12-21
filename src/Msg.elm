module Msg exposing (Msg(..))

import Http
import Session.Model exposing (Account, Network, Prices)
import Session.Update as Session exposing (Msg(..))


type Msg
    = GotPrices (Result Http.Error Prices)
    | ConnectExtension String
    | SwitchNetwork Network
    | SessionMsg Session.Msg
    | UpdateAccounts (List Account)
