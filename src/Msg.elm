module Msg exposing (Msg(..))

import Http
import Model exposing (Account, Network, Prices)


type Msg
    = UpdateAccounts (List Account)
    | ToggleAccountInfo String
    | ToggleShowNetworks
    | SwitchNetwork Network
    | GotPrices (Result Http.Error Prices)
    | ConnectExtension String
    | ToggleShowExtensions
