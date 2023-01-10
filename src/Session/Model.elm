module Session.Model exposing (..)


type alias Balance =
    { available : Int
    , staked : Int
    }


type alias Account =
    { address : String
    , name : String
    , balance : Maybe Balance
    , identity : Maybe String
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


type alias Model =
    { accounts : List Account
    , network : NetworkState
    , prices : Maybe Prices
    , extension : ExtensoinState
    }
