module Model exposing (..)


type alias Balance =
    { available : Int
    , staked : Int
    }


type alias Account =
    { address : String
    , show : Bool
    , name : String
    , balance : Maybe Balance
    }


type Network
    = Polkadot
    | Kusama


type alias NetworkState =
    { currentNetwork : Network
    , showNetworks : Bool
    }


type alias ExtensoinState =
    { currentExtension : Maybe String
    , extensions : List String
    , showExtensions : Bool
    }


type alias Usd =
    { usd : Float }


type alias Prices =
    { polkadot : Usd
    , kusama : Usd
    }


type Route
    = AccountsRoute
    | SendRoute (Maybe String)
    | NotFoundRoute


type alias Model =
    { accounts : List Account
    , count : Int
    , network : NetworkState
    , prices : Maybe Prices
    , extension : ExtensoinState
    , route : Route
    }
